provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
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
  tags             = [var.webapp_route_tags]

