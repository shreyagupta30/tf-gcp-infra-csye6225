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

resource "google_compute_firewall" "deny_ssh" {
  name    = "deny-ssh"
  network = google_compute_network.vpc_network.id

  deny {
    protocol = var.protocol
    ports    = var.deny_ports
  }
  source_ranges = var.source_ranges
}

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

resource "google_cloudfunctions_function" "mail_function" {
  name    = var.function_name
  runtime = var.function_runtime

  available_memory_mb          = var.function_memory
  source_archive_bucket        = google_storage_bucket.code_bucket.name
  trigger_http                 = var.http_trigger
  https_trigger_security_level = var.http_security_level
  source_archive_object        = var.function_source
  timeout                      = var.function_timeout
  entry_point                  = var.function_entry_point
  environment_variables = {
    DB_HOST     = google_sql_database_instance.main.private_ip_address
    DB_USER     = google_sql_user.webapp_user.name
    DB_PASSWORD = random_password.password.result
    DB_NAME     = google_sql_database.webapp_db.name
  }

  service_account_email = google_service_account.service_account_pubsub.email
}

resource "google_project_iam_member" "cloudfunctions_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.service_account_pubsub.email}"
}

resource "google_pubsub_subscription" "verify_email_sub" {
  name  = "verify_email_sub"
  topic = google_pubsub_topic.mailing_topic.name

  push_config {
    push_endpoint = google_cloudfunctions_function.mail_function.https_trigger_url
  }
}
