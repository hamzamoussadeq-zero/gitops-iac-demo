variable "project_id" {
  type        = string
  description = "GCP project ID for the prod environment."
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

variable "master_authorized_networks" {
  type = list(object({
    cidr = string
    name = string
  }))
  default = [
    {
      cidr = "10.0.0.0/8"
      name = "corporate-internal"
    }
  ]
  description = "CIDRs allowed to reach the GKE control plane."
}
