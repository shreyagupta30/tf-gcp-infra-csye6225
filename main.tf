provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_string" "random" {
  length  = var.string_length
  special = var.special_characters
}
resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp"
  ip_cidr_range = var.ip_cidr_range_webapp
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "db_subnet" {
  name                     = "db"
  ip_cidr_range            = var.ip_cidr_range_db
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_route" "webapp_route" {
  name             = var.webapp_subnet_name
  dest_range       = var.webapp_route_range
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = "default-internet-gateway"
  tags             = var.webapp_route_tags
}

#firewall rules
resource "google_compute_firewall" "webapp_traffic" {
  name    = var.name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = var.protocol
    ports    = var.allow_ports
  }

  source_tags   = var.source_tags
  source_ranges = var.source_ranges
}

# resource "google_compute_firewall" "deny_ssh" {
#   name    = "deny-ssh"
#   network = google_compute_network.vpc_network.id

#   deny {
#     protocol = var.protocol
#     ports    = var.deny_ports
#   }
#   source_ranges = var.source_ranges
# }

#serivce account 
resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
  project      = var.project_id
}

resource "google_project_iam_binding" "logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

# VM instance
resource "google_compute_instance" "webapp_vm" {
  name                      = "webapp-instance"
  machine_type              = var.machine_type
  zone                      = "${var.region}-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.image
      type  = var.type
      size  = var.size
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id
    access_config {
    }
  }
  tags                    = var.source_tags
  metadata_startup_script = <<-EOF
  #!/bin/bash

  # Create .env file
  cat > /opt/app/.env <<EOF2
  DB_HOST=${google_sql_database_instance.main.private_ip_address}
  DB_USER=${google_sql_user.webapp_user.name}
  DB_PASSWORD=${random_password.password.result}
  DB_NAME=${google_sql_database.webapp_db.name}
  DJANGO_SECRET_KEY=${random_string.random.result}
  GOOGLE_CLOUD_PROJECT_ID=${var.project_id}
  GOOGLE_CLOUD_PUBSUB_TOPIC_NAME=${google_pubsub_topic.mailing_topic.name}
  EOF2
  EOF

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
  depends_on = [
    google_service_account.service_account
  ]

}

#Private Service Access

resource "google_compute_global_address" "private_ip_address" {
  name          = var.private_service_name
  address_type  = var.address_type
  purpose       = var.purpose
  prefix_length = var.prefix_length
  network       = google_compute_network.vpc_network.id
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.name
  service                 = var.service_name
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


#cloudSQL setup
resource "random_id" "db_name_suffix" {
  byte_length = var.id_byte_length
}

resource "google_sql_database_instance" "main" {
  name                = "${var.db_name}-${random_id.db_name_suffix.hex}"
  database_version    = var.database_version
  deletion_protection = var.deletion_protection
  depends_on          = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.db_tier
    edition           = var.db_edition
    availability_type = var.availability_type
    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = google_compute_network.vpc_network.id
    }
    disk_type = var.disk_type
    disk_size = var.disk_size
  }
}

resource "google_sql_database" "webapp_db" {
  name     = "webapp_db"
  instance = google_sql_database_instance.main.id
}

resource "random_password" "password" {
  length  = var.password_length
  special = var.special_characters
}

resource "google_sql_user" "webapp_user" {
  name     = "webapp_user"
  instance = google_sql_database_instance.main.id
  password = random_password.password.result
}

# DNS setup
resource "google_dns_record_set" "a" {
  name         = var.dns_name
  managed_zone = var.zone_name
  type         = var.dns_record_type
  ttl          = var.dns_ttl
  rrdatas      = [google_compute_instance.webapp_vm.network_interface[0].access_config[0].nat_ip]
  project      = var.project_id
}

#pubsub topic
resource "google_service_account" "service_account_pubsub" {
  account_id   = "pubsub-service-account"
  display_name = "PubSub Service Account"
  project      = var.project_id
}

resource "google_project_iam_binding" "binding" {
  project = var.project_id
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.service_account_pubsub.email}",
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_pubsub_topic" "mailing_topic" {
  name                       = var.topic_name
  message_retention_duration = var.message_retention_duration
}

resource "google_storage_bucket" "code_bucket" {
  name     = var.bucket_name
  location = var.bucket_region
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.vpc-connector-name
  region        = var.region
  ip_cidr_range = var.vpc_connector_cidr
  network       = google_compute_network.vpc_network.id
}

resource "google_cloudfunctions2_function" "mail_function" {
  name     = var.function_name
  location = var.function_location

  build_config {
    entry_point = var.function_entry_point
    runtime     = var.function_runtime
    source {
      storage_source {
        bucket = google_storage_bucket.code_bucket.name
        object = var.function_source
      }
    }
  }
  service_config {
    min_instance_count = var.function_min_inst
    available_memory   = var.function_memory
    timeout_seconds    = var.function_timeout
    available_cpu      = var.function_cpu
    vpc_connector      = google_vpc_access_connector.vpc_connector.name
    environment_variables = {
      DB_HOST     = google_sql_database_instance.main.private_ip_address
      DB_USER     = google_sql_user.webapp_user.name
      DB_PASSWORD = random_password.password.result
      DB_NAME     = google_sql_database.webapp_db.name
    }
    ingress_settings               = var.ingress_setting
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.service_account_pubsub.email
  }
  event_trigger {
    trigger_region = var.trigger_region
    event_type     = var.event_type
    pubsub_topic   = google_pubsub_topic.mailing_topic.id
  }
}

resource "google_project_iam_member" "mail_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.service_account_pubsub.email}"
}

# compute instance template
resource "google_compute_instance_template" "webapp_vm_template" {
  name         = var.vm_template_name
  machine_type = var.machine_type
  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.proxy_only.id
    access_config {
    }
  }
  tags                    = var.target_tags
  metadata_startup_script = <<-EOF
  #!/bin/bash

  # Create .env file
  cat > /opt/app/.env <<EOF2
  DB_HOST=${google_sql_database_instance.main.private_ip_address}
  DB_USER=${google_sql_user.webapp_user.name}
  DB_PASSWORD=${random_password.password.result}
  DB_NAME=${google_sql_database.webapp_db.name}
  DJANGO_SECRET_KEY=${random_string.random.result}
  GOOGLE_CLOUD_PROJECT_ID=${var.project_id}
  GOOGLE_CLOUD_PUBSUB_TOPIC_NAME=${google_pubsub_topic.mailing_topic.name}
  EOF2
  EOF

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
  depends_on = [
    google_service_account.service_account
  ]
}


# health check 
resource "google_compute_region_health_check" "health-check" {
  name                = var.health_check_name
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  http_health_check {
    request_path = var.path
    port         = 8000
  }
}

# autoscaler
resource "google_compute_region_autoscaler" "autoscaler" {
  name   = var.autoscaler_name
  region = var.region
  target = google_compute_instance_group_manager.webapp-manager.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period
    mode            = "OFF" // Set mode to OFF

    cpu_utilization {
      target = var.cpu_target
    }
  }
}

resource "google_compute_instance_group_manager" "webapp-manager" {
  name = var.group_manager_name

  base_instance_name = "webapp"
  zone               = "${var.region}-a"

  version {
    instance_template = google_compute_instance_template.webapp_vm_template.id
  }

  # target_pools = [google_compute_target_pool.target_pool.id]
  # target_size  = 2
  named_port {
    name = "healthz-route"
    port = 8000
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.health-check.id
    initial_delay_sec = 500
  }
}

resource "google_compute_subnetwork" "proxy_only" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.129.0.0/23"
  network       = google_compute_network.vpc_network.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  region        = "us-east4"
  role          = "ACTIVE"
}

resource "google_compute_firewall" "default" {
  name = "fw-allow-health-check"
  allow {
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = var.priority
  source_ranges = var.firewall_source_tags
  target_tags   = var.target_tags
}

resource "google_compute_firewall" "allow_proxy" {
  name = "fw-allow-proxies"
  allow {
    ports    = ["443", "80", "8000"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = var.priority
  source_ranges = var.proxy_source_ranges
  target_tags   = var.target_tags
}

resource "google_compute_address" "default" {
  name         = "address-name"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
  region       = "us-east4"
}

resource "google_compute_region_backend_service" "default" {
  name                  = var.backend_service_name
  region                = var.region
  load_balancing_scheme = var.load_balancer_scheme
  health_checks         = [google_compute_region_health_check.health-check.id]
  protocol              = var.https_protocol
  session_affinity      = var.session_affinity
  timeout_sec           = 30
  backend {
    group           = google_compute_instance_group_manager.webapp-manager.instance_group
    balancing_mode  = var.balancing_mode
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_url_map" "default" {
  name            = var.url_map_name
  region          = var.region
  default_service = google_compute_region_backend_service.default.id
}

resource "google_compute_region_target_http_proxy" "default" {
  project = var.project_id
  name    = var.http_proxy_name
  region  = var.region
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_forwarding_rule" "default" {
  project    = var.project_id
  name       = var.forwarding_rule_name
  provider   = google-beta
  depends_on = [google_compute_subnetwork.proxy_only]
  region     = var.region

  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.port_range
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.vpc_network.id
  ip_address            = google_compute_address.default.id
  network_tier          = var.network_tier
}
