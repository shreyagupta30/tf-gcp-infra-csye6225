provider "google" {
    project     = var.project_id
    region      = var.region
}

resource "google_compute_network" "vpc_network" {
    name = var.vpc_name
    auto_create_subnetworks = false
    routing_mode = "REGIONAL"
    delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp_subnet" {
    name          = "webapp"
    ip_cidr_range = "10.0.0.0/24"
    region        = var.region
    network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "db_subnet" {
    name          = "db"
    ip_cidr_range = "10.0.1.0/24"
    region        = var.region
    network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_route" "webapp_route" {
    name        = "webapp-route"
    dest_range  = "0.0.0.0/0"
    network     = google_compute_network.vpc_network.self_link
    next_hop_gateway = "default-internet-gateway"
    tags        = ["webapp"]
}
