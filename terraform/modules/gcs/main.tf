resource "google_storage_bucket" "this" {
  name          = var.name
  location      = var.location
  force_destroy = var.force_destroy

  public_access_prevention    = var.public_access_prevention
  uniform_bucket_level_access = var.uniform_bucket_level_access

  dynamic "versioning" {
    for_each = var.versioning_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "logging" {
    for_each = var.log_bucket != null ? [1] : []
    content {
      log_bucket        = var.log_bucket
      log_object_prefix = var.name
    }
  }

  dynamic "encryption" {
    for_each = var.kms_key != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key
    }
  }
}
