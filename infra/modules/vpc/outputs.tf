output "network_name" {
  value = google_compute_network.this.name
}

output "network_id" {
  value = google_compute_network.this.id
}

output "subnet_name" {
  value = google_compute_subnetwork.this.name
}

output "subnet_id" {
  value = google_compute_subnetwork.this.id
}

output "subnet_cidr" {
  value = google_compute_subnetwork.this.ip_cidr_range
}

output "pods_range_name" {
  value = var.pods_range_name
}

output "services_range_name" {
  value = var.services_range_name
}

output "router_name" {
  value = var.enable_cloud_nat ? google_compute_router.this[0].name : null
}

output "nat_name" {
  value = var.enable_cloud_nat ? google_compute_router_nat.this[0].name : null
}
