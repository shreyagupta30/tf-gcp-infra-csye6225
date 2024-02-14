variable "project_id" {
  default = "lateral-scion-414218"
}
variable "region" {
  default = "us-east4"
}
variable "vpc_name" {
  default = "csye-tf"
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
  default = "webapp"
}
