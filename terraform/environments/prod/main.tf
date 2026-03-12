# =============================================================================
# PROD environment — all security controls enabled.
# This is the target state every environment should eventually reach.
# Checkov should return zero HIGH/CRITICAL failures on this file.
# =============================================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Uncomment and set bucket name to enable remote state
  # backend "gcs" {
  #   bucket = "my-company-tfstate-prod"
  #   prefix = "environments/prod"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  name         = "prod-vpc"
  region       = var.region
  primary_cidr = "10.20.0.0/20"
  secondary_ranges = {
    pods     = "10.200.0.0/16"
    services = "10.201.0.0/20"
  }
}

# Dedicated logging bucket — receives access logs from other buckets
module "log_bucket" {
  source = "../../modules/gcs"

  name                        = "prod-access-logs-${var.project_id}"
  location                    = "EU"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning_enabled          = true
  log_bucket                  = null # log bucket does not log itself
}

# App assets bucket — all controls enabled, logs to the dedicated log bucket
module "app_bucket" {
  source = "../../modules/gcs"

  name                        = "prod-app-assets-${var.project_id}"
  location                    = "EU"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning_enabled          = true
  log_bucket                  = module.log_bucket.bucket_name
}

# GKE cluster — private nodes, Workload Identity, shielded nodes, network policy
module "gke" {
  source = "../../modules/gke"

  name       = "prod-cluster"
  location   = var.region # regional cluster for HA
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnetwork_name

  enable_legacy_abac     = false
  enable_private_nodes   = true
  enable_private_endpoint = false # keep public endpoint, restricted by authorized networks
  enable_shielded_nodes  = true
  network_policy_enabled = true

  master_ipv4_cidr_block = "172.16.1.0/28"
  workload_pool          = "${var.project_id}.svc.id.goog"

  master_authorized_networks = var.master_authorized_networks

  node_service_account = var.node_sa_email
  node_count           = 1 # per-zone; regional cluster = 3 total
  machine_type         = "e2-standard-4"
}
