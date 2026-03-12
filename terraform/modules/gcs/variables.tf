variable "name" {
  type        = string
  description = "Bucket name. Must be globally unique."
}

variable "location" {
  type        = string
  default     = "EU"
  description = "GCS multi-region or region location."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow Terraform to destroy non-empty bucket. Never true in prod."
}

variable "public_access_prevention" {
  type        = string
  default     = "enforced"
  description = "'enforced' blocks all public access. 'inherited' respects org policy."
}

variable "uniform_bucket_level_access" {
  type        = bool
  default     = true
  description = "Enforce IAM-only access. Disables per-object ACLs."
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "Enable object versioning for recovery and audit."
}

variable "log_bucket" {
  type        = string
  default     = null
  description = "Target bucket for access logs. null disables logging (CKV_GCP_62 will fail)."
}

variable "kms_key" {
  type        = string
  default     = null
  description = "CMEK key for encryption. null uses Google-managed keys."
}
