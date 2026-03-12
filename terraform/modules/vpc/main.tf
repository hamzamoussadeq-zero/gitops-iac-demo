resource "google_compute_network" "this" {
  name                    = var.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "primary" {
  name          = "${var.name}-primary"
  network       = google_compute_network.this.id
  region        = var.region
  ip_cidr_range = var.primary_cidr

  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ranges
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Explicit deny-all ingress (lower priority than specific allow rules)
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${var.name}-deny-all-ingress"
  network   = google_compute_network.this.id
  priority  = 65534
  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow internal traffic within the VPC subnet only
resource "google_compute_firewall" "allow_internal" {
  name      = "${var.name}-allow-internal"
  network   = google_compute_network.this.id
  priority  = 1000
  direction = "INGRESS"

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = [var.primary_cidr]
}
