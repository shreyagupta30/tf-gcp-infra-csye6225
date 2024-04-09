# Project creation
provider "google" {
  project = var.project_id
  region  = var.region
}

# random string for django secrets
resource "random_string" "random" {
  length  = var.string_length
  special = var.special_characters
}

# SSL certificate
resource "google_compute_region_ssl_certificate" "ssl" {
  name_prefix = "lb-ssl-certificate"
  private_key = file("./csye6225-assignment.store-key.pem")
  certificate = file("./csye6225-assignment.store.pem")
  lifecycle {
    create_before_destroy = true
  }
}

# VPC network
resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

# webapp subnet
resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp"
  ip_cidr_range = var.ip_cidr_range_webapp
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# db subnet
resource "google_compute_subnetwork" "db_subnet" {
  name                     = "db"
  ip_cidr_range            = var.ip_cidr_range_db
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

#proxy only subnet
resource "google_compute_subnetwork" "proxy_only" {
  name          = var.proxy_name
  ip_cidr_range = var.proxy_ip_cidr_range
  network       = google_compute_network.vpc_network.id
  purpose       = var.proxy_purpose
  region        = var.region
  role          = var.proxy_role
}

#serivce account 
resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
  project      = var.project_id
}


resource "google_compute_firewall" "healthz-firewall" {
  name = var.firewall_name
  allow {
    protocol = var.firewall_protocol
  }
  direction     = var.firewal_direction
  network       = google_compute_network.vpc_network.id
  priority      = var.firewall_priority
  source_ranges = var.firewall_source_ranges
  target_tags   = var.target_tags
}

resource "google_compute_firewall" "allow_proxy" {
  name = var.firewall_proxy_name
  allow {
    ports    = var.firewall_ports
    protocol = var.firewall_protocol
  }
  direction     = var.firewal_direction
  network       = google_compute_network.vpc_network.id
  priority      = var.firewall_priority
  source_ranges = var.firewall_proxy_source_ranges
  target_tags   = var.target_tags
}

# compute instance template
resource "google_compute_instance_template" "webapp_vm_template" {
  name         = var.vm_template_name
  machine_type = var.machine_type
  region       = var.region
  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
    type         = var.vm_template_type
  }

  network_interface {
    access_config {
    }
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id
  }
  tags = var.target_tags

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
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/pubsub", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  depends_on = [
    google_service_account.service_account
  ]
}

resource "google_compute_instance_group_manager" "group_manager" {
  name = var.group_manager_name
  zone = var.zone
  named_port {
    name = var.group_manager_named_port_name
    port = var.group_manager_named_port_port
  }
  version {
    instance_template = google_compute_instance_template.webapp_vm_template.id
    name              = "primary"
  }
  base_instance_name = var.group_manager_target_name
  target_size        = var.group_manager_target_size
}

resource "google_compute_address" "compute-address" {
  name         = var.compute_address_name
  address_type = var.lb_address_type
  network_tier = var.network_tier
  region       = var.region
}

resource "google_compute_region_health_check" "health-check" {
  name               = var.health_check_name
  check_interval_sec = var.check_interval_sec
  healthy_threshold  = var.healthy_threshold
  http_health_check {
    port_specification = var.port_specification
    proxy_header       = var.proxy_header
    request_path       = var.path
  }
  region              = var.region
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold
}

resource "google_compute_region_backend_service" "backend-service" {
  name                  = var.backend_service_name
  region                = var.region
  load_balancing_scheme = var.load_balancing_scheme
  health_checks         = [google_compute_region_health_check.health-check.id]
  protocol              = var.backend_service_protocol
  session_affinity      = var.session_affinity
  timeout_sec           = var.timeout_sec
  backend {
    group           = google_compute_instance_group_manager.group_manager.instance_group
    balancing_mode  = var.balancing_mode
    capacity_scaler = var.capacity
  }
}

resource "google_compute_region_url_map" "url_map" {
  name            = var.url_map_name
  region          = var.region
  default_service = google_compute_region_backend_service.backend-service.id
}

resource "google_compute_region_target_https_proxy" "target_https_proxy" {
  name             = var.target_https_proxy_name
  region           = var.region
  url_map          = google_compute_region_url_map.url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.ssl.id]
}

resource "google_compute_forwarding_rule" "lb-forwarding-rule" {
  project    = var.project_id
  name       = var.forwarding_rule_name
  provider   = google-beta
  depends_on = [google_compute_subnetwork.proxy_only]
  region     = var.region

  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.forwarding_port_range
  target                = google_compute_region_target_https_proxy.target_https_proxy.id
  network               = google_compute_network.vpc_network.id
  ip_address            = google_compute_address.compute-address.id
  network_tier          = var.network_tier
}

# autoscaler
resource "google_compute_autoscaler" "autoscaler" {
  name   = var.autoscaler_name
  zone   = var.zone
  target = google_compute_instance_group_manager.group_manager.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.cpu_target
    }
  }
}

# IAM roles
# Logging roles
resource "google_project_iam_binding" "logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

# Monitoring roles
resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
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

# Private VPC connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.name
  service                 = var.service_name
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

#cloudSQL setup
resource "random_id" "db_name_suffix" {
  byte_length = var.id_byte_length
}

# SQL database instance
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

# SQL database
resource "google_sql_database" "webapp_db" {
  name     = "webapp_db"
  instance = google_sql_database_instance.main.id
}

# random password for SQL user
resource "random_password" "password" {
  length  = var.password_length
  special = var.special_characters
}

# SQL user
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
  rrdatas      = [google_compute_address.compute-address.address]
  project      = var.project_id
}

#pubsub topic
resource "google_service_account" "service_account_pubsub" {
  account_id   = "pubsub-service-account"
  display_name = "PubSub Service Account"
  project      = var.project_id
}

#pubsub roles
resource "google_project_iam_binding" "binding" {
  project = var.project_id
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.service_account_pubsub.email}",
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_project_iam_binding" "subscriber_binding" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"

  members = [
    "serviceAccount:${google_service_account.service_account_pubsub.email}",
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}


#mailing topic
resource "google_pubsub_topic" "mailing_topic" {
  name                       = var.topic_name
  message_retention_duration = var.message_retention_duration
}

#code bucket
resource "google_storage_bucket" "code_bucket" {
  name     = var.bucket_name
  location = var.bucket_region
}

#vpc connector
resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.vpc-connector-name
  region        = var.region
  ip_cidr_range = var.vpc_connector_cidr
  network       = google_compute_network.vpc_network.id
}

#cloud function
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
    trigger_region = var.region
    event_type     = var.event_type
    pubsub_topic   = google_pubsub_topic.mailing_topic.id
  }
}

#mail invoker
resource "google_project_iam_member" "mail_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.service_account_pubsub.email}"
}
