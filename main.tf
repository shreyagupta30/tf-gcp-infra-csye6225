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

# VM instance
resource "google_compute_instance" "webapp_vm" {
  name         = "webapp-instance"
  machine_type = var.machine_type
  zone         = "${var.region}-a"

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
