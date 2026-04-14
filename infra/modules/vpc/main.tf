# ------------------------------------------------------------------------------
# VPC module — custom VPC with subnet, Cloud NAT, and Private Google Access
# ------------------------------------------------------------------------------
# Opinionated for article testing:
#   - Single custom subnet with secondary ranges for GKE pods/services
#   - Cloud NAT via Cloud Router (one NAT per region, mirrors AWS single-NAT pattern)
#   - Private Google Access enabled by default (saves Cloud NAT data processing $$$)
#   - No VPC flow logs (expensive, enable per-article if needed)
# ------------------------------------------------------------------------------

resource "google_compute_network" "this" {
  name                    = var.name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
}

resource "google_compute_subnetwork" "this" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id

  private_ip_google_access = var.enable_private_google_access

  dynamic "secondary_ip_range" {
    for_each = var.pods_range_name != null ? [1] : []
    content {
      range_name    = var.pods_range_name
      ip_cidr_range = var.pods_cidr
    }
  }

  dynamic "secondary_ip_range" {
    for_each = var.services_range_name != null ? [1] : []
    content {
      range_name    = var.services_range_name
      ip_cidr_range = var.services_cidr
    }
  }
}

# ------------------------------------------------------------------------------
# Cloud Router + Cloud NAT (if enabled)
# ------------------------------------------------------------------------------
resource "google_compute_router" "this" {
  count   = var.enable_cloud_nat ? 1 : 0
  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  count  = var.enable_cloud_nat ? 1 : 0
  name   = "${var.name}-nat"
  router = google_compute_router.this[0].name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}

# ------------------------------------------------------------------------------
# Firewall — allow internal, health checks, IAP SSH
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name}-allow-internal"
  network = google_compute_network.this.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr]
  priority      = 1000
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.name}-allow-health-checks"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
  }

  # Google health check probe ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  priority      = 1000
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.name}-allow-iap-ssh"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP IP range
  source_ranges = ["35.235.240.0/20"]
  priority      = 1000
}
