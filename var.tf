variable "project_id" {
  default = "lateral-scion-414218"
}
variable "region" {
  default = "us-east4"
}
variable "vpc_name" {
  default = "csye-tf"
}

variable "ip_cidr_range_webapp" {
  default = "10.0.0.0/24"
}

variable "ip_cidr_range_db" {
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
  default = "e2-medium"
}

variable "image" {
  default = "centos-csye-deploy"
}

variable "type" {
  default = "pd-balanced"
}

variable "db_name" {
  default = "db-instance"
}
variable "size" {
  default = 100
}

variable "deletion_protection" {
  default = false
}

variable "prefix_length" {
  default = 16
}
variable "availability_type" {
  default = "REGIONAL"
}

variable "disk_type" {
  default = "PD_SSD"
}

variable "disk_size" {
  default = 100
}

variable "ipv4_enabled" {
  default = false
}

variable "address_type" {
  default = "INTERNAL"
}

variable "purpose" {
  default = "VPC_PEERING"
}

variable "database_version" {
  default = "POSTGRES_15"
}

variable "db_tier" {
  default = "db-f1-micro"
}

variable "db_edition" {
  default = "ENTERPRISE"
}

variable "private_service_name" {
  default = "global-psconnect-ip"
}

variable "service_name" {
  default = "servicenetworking.googleapis.com"
}

variable "password_length" {
  default = 8
}

variable "special_characters" {
  default = true
}

variable "string_length" {
  default = 50
}

variable "id_byte_length" {
  default = 4
}

variable "zone_name" {
  default = "shreyagupta-csye"
}

variable "dns_name" {
  default = "csye6225-assignment.store."
}

variable "service_account_id" {
  default = "service-account-id"
}

variable "service_account_name" {
  default = "service-account"
}

variable "dns_record_type" {
  default = "A"
}

variable "dns_ttl" {
  default = 300
}

variable "topic_name" {
  default = "mailing_topic"
}

variable "message_retention_duration" {
  default = "604800s"
}

variable "subscription_name" {
  default = "verify_email_sub"
}

variable "function_name" {
  default = "verify_email"
}

variable "function_runtime" {
  default = "python311"
}

variable "function_entry_point" {
  default = "runner_func"
}

variable "function_memory" {
  default = 256
}

variable "function_timeout" {
  default = 120
}

variable "function_source" {
  default = "deploy.zip"
}

variable "bucket_name" {
  default = "csye6225-assignment"
}

variable "bucket_region" {
  default = "US"
}

variable "http_trigger" {
  default = true
}

variable "http_security_level" {
  default = "SECURE_ALWAYS"
}

variable "function_source_file" {
  default = "runner.py"
}
