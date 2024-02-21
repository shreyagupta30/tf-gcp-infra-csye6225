provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  for_each = var.vpc_names
  name  = each.value
  auto_create_subnetworks = false
  routing_mode = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp"
  ip_cidr_range = var.ip_cir_range_webapp
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db"
  ip_cidr_range = var.ip_cir_range_db
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_route" "webapp_route" {
  name             = var.webapp_subnet_name
  dest_range       = var.webapp_route_range
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = "default-internet-gateway"
  tags             = var.webapp_route_tags
}

resource "google_compute_firewall" "webapp_traffic" {
  name    = var.name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = var.protocol
    ports    = var.allow_ports
  }

  source_tags = var.source_tags
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
  tags = var.source_tags
}
