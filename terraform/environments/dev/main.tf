# =============================================================================
# DEV environment — intentionally uses insecure module inputs to demonstrate
# what Checkov catches before these configs would ever reach production.
#
# Insecure settings are labeled with the Checkov check IDs they trigger.
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
  #   bucket = "my-company-tfstate-dev"
  #   prefix = "environments/dev"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  name         = "dev-vpc"
  region       = var.region
  primary_cidr = "10.10.0.0/20"
  secondary_ranges = {
    pods     = "10.100.0.0/16"
    services = "10.101.0.0/20"
  }
}

# -----------------------------------------------------------------------------
# [INSECURE] GCS app assets bucket
# Checkov failures expected:
#   CKV_GCP_78  — public_access_prevention = "inherited" (not enforced)
#   CKV_GCP_62  — no access logging (log_bucket = null)
#   CKV_GCP_29  — versioning disabled
# -----------------------------------------------------------------------------
module "app_bucket" {
  source = "../../modules/gcs"

  name                        = "dev-app-assets-${var.project_id}"
  location                    = "EU"
  public_access_prevention    = "inherited" # CKV_GCP_78: allows public ACLs
  uniform_bucket_level_access = false       # CKV_GCP_???:  per-object ACLs allowed
  versioning_enabled          = false       # CKV_GCP_29: no object versioning
  log_bucket                  = null        # CKV_GCP_62: no access logging
}

# -----------------------------------------------------------------------------
# [INSECURE] GKE cluster
# Checkov failures expected:
#   CKV_GCP_25  — legacy ABAC enabled
#   CKV_GCP_65  — Workload Identity not configured
#   CKV_GCP_7   — network policy disabled
#   CKV_GCP_12  — private nodes disabled (nodes get public IPs)
# -----------------------------------------------------------------------------
module "gke" {
  source = "../../modules/gke"

  name       = "dev-cluster"
  location   = "${var.region}-b"
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnetwork_name

  enable_legacy_abac     = true  # CKV_GCP_25: legacy ABAC on
  enable_private_nodes   = false # CKV_GCP_12: nodes get public IPs
  enable_shielded_nodes  = false # CKV_GCP_71: no shielded nodes
  workload_pool          = null  # CKV_GCP_65: Workload Identity off
  network_policy_enabled = false # CKV_GCP_7:  network policy off

  master_authorized_networks = [] # CKV_GCP_25: any IP can reach control plane

  node_service_account = var.node_sa_email
}
# test
