variable "project_id" {
  default = "lateral-scion-414218"
}
variable "region" {
  default = "us-east4"
}
variable "vpc_names" {
  type = list(string)
  default = ["csye-tf","csye-tf-2"]
}

variable "ip_cir_range_webapp" {
  default = "10.0.0.0/24"
}

variable "ip_cir_range_db" {
  default = "10.0.1.0/24"
}

variable "webapp_subnet_name" {
  default = "webapp-route"
}

variable "webapp_route_range" {
  default = "0.0.0.0/0"
}

variable "webapp_route_tags" {
  default = ["webapp"]
}
variable "routing_mode" {
  default = "REGIONAL"
}

variable "name" {
  default = "webapp-traffic"
}
variable "protocol" {
  default = "tcp" 
}

variable "allow_ports" {
  default = ["8000"]
}
variable "source_tags" {
  default = ["webapp"]
}

variable "source_ranges" {
  default = ["0.0.0.0/0"]
}

variable "deny_ports" {
  default = ["22"]
}

variable "machine_type" {
  default = "e2-micro" 
}

variable "image" {
  default = ""
}

variable "type" {
  default = "pd-balanced"
}

variable "size" {
  default = "100"
}
