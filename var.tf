variable "project_id" {
  default = "csye-6225-419603"
}
variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-a"
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
variable "firewall_source_ranges" {
  default = ["130.211.0.0/22", "35.191.0.0/16"]
}

variable "firewall_name" {
  default = "healthz-firewall"
}

variable "firewal_direction" {
  default = "INGRESS"
}

variable "firewall_protocol" {
  default = "TCP"
}

variable "firewall_ports" {
  default = ["80", "443", "8000"]
}

variable "firewall_priority" {
  default = 1000
}

variable "firewall_proxy_source_ranges" {
  default = ["10.129.0.0/23"]
}
variable "proxy_name" {
  default = "webapp-proxy"
}

variable "proxy_ip_cidr_range" {
  default = "10.129.0.0/23"
}


variable "proxy_purpose" {
  default = "REGIONAL_MANAGED_PROXY"
}

variable "proxy_role" {
  default = "ACTIVE"
}

variable "firewall_proxy_name" {
  default = "webapp-firewall-proxy"
}

variable "vm_template_type" {
  default = "pd-balanced"
}


variable "machine_type" {
  default = "e2-medium"
}

variable "image" {
  default = "centos-csye-deploy"
}

variable "group_manger_name" {
  default = "webapp-group-manager"
}

variable "group_manager_named_port_name" {
  default = "http"
}

variable "backend_service_protocol" {
  default = "HTTP"
}

variable "group_manager_named_port_port" {
  default = 8000
}

variable "group_manager_target_name" {
  default = "webapp-target"
}

variable "group_manager_target_size" {
  default = 2
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
  default = "csye6225-dns"
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
  default = "256M"
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
  default = "csye6225-bucket-new"
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

variable "event_type" {
  default = "google.cloud.pubsub.topic.v1.messagePublished"
}

variable "ip_protocol" {
  default = "TCP"
}

variable "load_balancing_scheme" {
  default = "EXTERNAL_MANAGED"
}

variable "forwarding_port_range" {
  default = "443"
}
variable "forwarding_rule_name" {
  default = "lb-forwarding-rule"
}

variable "network_tier" {
  default = "PREMIUM"
}

variable "http_proxy_name" {
  default = "lb-http-proxy"
}

variable "url_map_name" {
  default = "lb-url-map"
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

variable "capacity" {
  default = 1.0
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
  default = "lb-health-check"
}

variable "compute_address_name" {
  default = "compute-address-name"
}

variable "target_https_proxy_name" {
  default = "lb-target-https-proxy"
}
variable "check_interval_sec" {
  default = 5
}

variable "timeout_sec" {
  default = 5
}

variable "healthy_threshold" {
  default = 2
}
variable "port_specification" {
  default = "USE_SERVING_PORT"
}

variable "proxy_header" {
  default = "NONE"
}

variable "unhealthy_threshold" {
  default = 4
}

variable "path" {
  default = "/healthz"
}

variable "backend_service_name" {
  default = "lb-backend-service"
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
