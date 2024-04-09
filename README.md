# Terraform infrastructure on Google Cloud Platform 

## Overview

This project uses Terraform to manage infrastructure on Google Cloud Platform (GCP). The configuration files included in this project are:

- `main.tf`: This is the primary configuration file for Terraform. It contains the definitions needed to create, modify, or delete resources such as virtual machines, network configurations, and more.

- `var.tf`: This file is used to declare variables. Variables in Terraform allow for the definition of centrally controlled, reusable values. The goal is to define a variable once and reference it multiple times throughout the configuration.

## Usage

To use this configuration, you need to have Terraform installed on your machine. Once installed, navigate to the directory containing the `main.tf` file and run the following commands:

``` bash
# Initialize Terraform in your directory
terraform init

# Plan and see the changes that will be made
terraform plan

# Apply the changes
terraform apply
```

> **Note:** The actual behavior and resources created will depend on the specific content of the `main.tf` and variables declared in `var.tf` file.


## Google Cloud Platform APIs

The following APIs must be enabled on Google Cloud Platform for the successful creation of the resources:

1. Compute Engine API
2. Serverless VPC Access API
3. Service Networking API
4. Cloud DNS API
5. Eventarc API
6. Cloud Run Admin API
7. Cloud Build API
8. Cloud Functions API
9. Cloud Logging API
10. Cloud Pub/Sub API

> **Note:** Please ensure these APIs are enabled in your GCP project before running the Terraform commands.
