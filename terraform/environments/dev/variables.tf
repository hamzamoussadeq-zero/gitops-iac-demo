variable "project_id" {
  type        = string
  description = "GCP project ID for the dev environment."
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "Default GCP region."
}

variable "node_sa_email" {
  type        = string
  description = "Service account email for GKE node pool."
}
