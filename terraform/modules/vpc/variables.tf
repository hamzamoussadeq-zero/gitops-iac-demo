variable "name" {
  type        = string
  description = "VPC name prefix."
}

variable "region" {
  type        = string
  description = "GCP region for the subnetwork."
}

variable "primary_cidr" {
  type        = string
  description = "Primary IP range for the subnetwork."
}

variable "secondary_ranges" {
  type        = map(string)
  default     = {}
  description = "Secondary IP ranges keyed by range name (e.g. pods, services)."
}
