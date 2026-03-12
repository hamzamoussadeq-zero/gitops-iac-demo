resource "google_container_cluster" "this" {
  name                     = var.name
  location                 = var.location
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  enable_legacy_abac = var.enable_legacy_abac

  # Disable basic auth and client certificate
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr
          display_name = cidr_blocks.value.name
        }
      }
    }
  }

  dynamic "workload_identity_config" {
    for_each = var.workload_pool != null ? [1] : []
    content {
      workload_pool = var.workload_pool
    }
  }

  release_channel {
    channel = var.release_channel
  }

  network_policy {
    enabled = var.network_policy_enabled
  }

  addons_config {
    network_policy_config {
      disabled = !var.network_policy_enabled
    }
  }
}

resource "google_container_node_pool" "primary" {
  name     = "${var.name}-primary"
  cluster  = google_container_cluster.this.name
  location = var.location

  node_count = var.node_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    service_account = var.node_service_account
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    # Disable legacy metadata endpoints (GCE metadata v1 API)
    metadata = {
      disable-legacy-endpoints = "true"
    }

    dynamic "shielded_instance_config" {
      for_each = var.enable_shielded_nodes ? [1] : []
      content {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }
  }
}
