# ------------------------------------------------------------------------------
# GKE Autopilot module — thin wrapper for article testing
# ------------------------------------------------------------------------------
# Opinionated for article testing:
#   - Autopilot mode (Workload Identity always on, no node management)
#   - Private nodes with Cloud NAT for outbound (mirrors AWS private subnets)
#   - Public master endpoint (convenient for article testing, NOT production)
#   - Regular release channel (stable K8s version)
#   - Deletion protection off (fast teardown)
# ------------------------------------------------------------------------------

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  enable_autopilot = true

  release_channel {
    channel = var.release_channel
  }

  network    = var.network_name
  subnetwork = var.subnet_name

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  dynamic "private_cluster_config" {
    for_each = var.enable_private_nodes ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = false
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  deletion_protection = var.deletion_protection

  resource_labels = var.common_labels
}
