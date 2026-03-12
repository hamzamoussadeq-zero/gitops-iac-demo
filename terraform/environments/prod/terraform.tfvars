project_id    = "my-company-prod"
region        = "europe-west1"
node_sa_email = "gke-nodes@my-company-prod.iam.gserviceaccount.com"

master_authorized_networks = [
  { cidr = "10.0.0.0/8", name = "corporate-internal" },
  { cidr = "192.168.100.0/24", name = "vpn-egress" },
]
