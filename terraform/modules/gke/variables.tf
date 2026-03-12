variable "name" {
  type        = string
  description = "Cluster name."
}

variable "location" {
  type        = string
  description = "GCP region or zone for the cluster."
}

variable "network" {
  type        = string
  description = "VPC network name."
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork name."
}

variable "enable_legacy_abac" {
  type        = bool
  default     = false
  description = "Enable legacy ABAC. Should always be false in production (CKV_GCP_25 will fail if true)."
}

variable "enable_private_nodes" {
  type        = bool
  default     = true
  description = "Give nodes private IPs only. Required for private clusters (CKV_GCP_25)."
}

variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Make the control plane endpoint private-only. Set true if VPN/interconnect is available."
}

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.16.0.32/28"
  description = "CIDR for the control plane internal IP range."
}

variable "master_authorized_networks" {
  type = list(object({
    cidr = string
    name = string
  }))
  default     = []
  description = "CIDRs allowed to reach the control plane. Empty = unrestricted (CKV_GCP_25)."
}

variable "workload_pool" {
  type        = string
  default     = null
  description = "Workload Identity pool (e.g. my-project.svc.id.goog). null disables WI (CKV_GCP_65)."
}

variable "release_channel" {
  type        = string
  default     = "REGULAR"
  description = "GKE release channel: RAPID, REGULAR, or STABLE."
}

variable "network_policy_enabled" {
  type        = bool
  default     = true
  description = "Enable Kubernetes network policy enforcement."
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of nodes per zone in the primary node pool."
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "GCE machine type for nodes."
}

variable "disk_size_gb" {
  type        = number
  default     = 50
  description = "Boot disk size per node in GB."
}

variable "node_service_account" {
  type        = string
  description = "Dedicated service account email for GKE nodes. Never use the default SA."
}

variable "enable_shielded_nodes" {
  type        = bool
  default     = true
  description = "Enable Shielded VM (secure boot + integrity monitoring) on nodes (CKV_GCP_71)."
}
