# CSYE6225 - Cloud Computing Infrastructure

This repository contains the Terraform configuration for setting up a production-grade infrastructure on Google Cloud Platform (GCP) for a web application.

## Infrastructure Components

### Network Infrastructure
- **VPC Network**: Custom VPC network with regional routing mode
- **Subnets**:
  - Webapp Subnet: For hosting web application instances
  - Database Subnet: For Cloud SQL instance with private IP
  - Proxy-only Subnet: For load balancer
- **Firewall Rules**: Configured for health checks and proxy access
- **Routes**: Internet gateway route for webapp subnet

### Compute Resources
- **Instance Template**: CentOS-based template for web application VMs
- **Instance Group Manager**: Manages web application instances
- **Autoscaler**: Automatically scales instances based on CPU utilization
- **Load Balancer**: HTTPS load balancer with SSL certificate

### Database
- **Cloud SQL**: PostgreSQL 15 instance with private IP
- **Database**: Dedicated database for the web application
- **User**: Database user with secure password

### Storage & Messaging
- **Cloud Storage**: Bucket for application code and assets
- **Pub/Sub**: Topic for email notifications
- **Cloud Functions**: Function for email verification

### Security
- **Service Accounts**: Dedicated service accounts for different components
- **IAM Roles**: Appropriate permissions for service accounts
- **KMS**: Key management for encryption
- **SSL Certificate**: For HTTPS load balancer

### DNS
- **Cloud DNS**: Managed DNS zone for the application domain

## Prerequisites
- Google Cloud Platform account
- Terraform installed
- GCP project with billing enabled
- Required API services enabled in GCP project
- SSL certificates for HTTPS load balancer

## Configuration
The infrastructure is configured using variables defined in `var.tf`. Key configurations include:
- Project ID: csye-6225-419603
- Region: us-east4
- Zone: us-east4-a
- Machine Type: e2-medium
- Database Version: PostgreSQL 15
- Database Tier: db-f1-micro

## Deployment
1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the infrastructure:
   ```bash
   terraform apply
   ```

## Security Features
- Private VPC network with restricted access
- Encrypted storage using KMS
- SSL/TLS for HTTPS traffic
- Private IP for database
- Service account-based authentication
- Firewall rules for controlled access

## Monitoring & Logging
- Cloud Logging integration
- Cloud Monitoring setup
- Health checks for load balancer

## Cleanup
To destroy the infrastructure:
```bash
terraform destroy
```

## Notes
- Ensure all required API services are enabled in the GCP project
- Keep SSL certificates secure and up to date
- Monitor costs regularly
- Follow security best practices for managing secrets and credentials
