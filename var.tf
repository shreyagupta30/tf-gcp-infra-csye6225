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
  default = ["8000", "22"]
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

variable "vpc-connector-name" {
  default = "vpc-connector"
}

variable "vpc_connector_cidr" {
  default = "10.10.0.0/28"
}
variable "function_location" {
  default = "us-east4"
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
  default = "256Mi"
}

variable "function_timeout" {
  default = 60
}

variable "function_cpu" {
  default = 1
}
variable "function_min_inst" {
  default = 1
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

variable "function_source_file" {
  default = "main.py"
}

variable "ingress_setting" {
  default = "ALLOW_INTERNAL_ONLY"
}

variable "trigger_region" {
  default = "us-east4"
}

variable "event_type" {
  default = "google.cloud.pubsub.topic.v1.messagePublished"
}

variable "forwarding_rule_name" {
  default = "lb-forwarding-rule"
}

variable "ip_protocol" {
  default = "TCP"
}

variable "load_balancing_scheme" {
  default = "EXTERNAL_MANAGED"
}

variable "port_range" {
  default = "8000"
}

variable "network_tier" {
  default = "STANDARD"
}

variable "http_proxy_name" {
  default = "lb-http-proxy"
}

variable "url_map_name" {
  default = "lb-url-map"
}

variable "backend_service_name" {
  default = "lb-backend-service"
}

variable "load_balancer_scheme" {
  default = "EXTERNAL_MANAGED"
}

variable "https_protocol" {
  default = "HTTPS"
}

variable "session_affinity" {
  default = "NONE"
}

variable "balancing_mode" {
  default = "UTILIZATION"
}


variable "lb_address_type" {
  default = "EXTERNAL"
}

variable "lb_address_name" {
  default = "address_name"
}

variable "target_tags" {
  default = ["load-balanced-backend"]
}

variable "proxy_source_ranges" {
  default = ["10.129.0.0/23"]
}

variable "priority" {
  default = 1000
}

variable "firewall_source_tags" {
  default = ["130.211.0.0/22", "35.191.0.0/16"]
}

variable "vm_template_name" {
  default = "webapp-instance-template"
}

variable "health_check_name" {
  default = "webapp-health-check"
}

variable "check_interval_sec" {
  default = 1
}

variable "timeout_sec" {
  default = 1
}

variable "healthy_threshold" {
  default = 4
}

variable "unhealthy_threshold" {
  default = 4
}

variable "path" {
  default = "/healthz"
}

variable "autoscaler_name" {
  default = "webapp-autoscaler"
}

variable "max_replicas" {
  default = 5
}
variable "min_replicas" {
  default = 1
}

variable "cooldown_period" {
  default = 60
}

variable "cpu_target" {
  default = 0.05
}

variable "group_manager_name" {
  default = "webapp-group-manager"
}
