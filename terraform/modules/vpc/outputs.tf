output "network_id" {
  value = google_compute_network.this.id
}

output "network_name" {
  value = google_compute_network.this.name
}

output "subnetwork_id" {
  value = google_compute_subnetwork.primary.id
}

output "subnetwork_name" {
  value = google_compute_subnetwork.primary.name
}
