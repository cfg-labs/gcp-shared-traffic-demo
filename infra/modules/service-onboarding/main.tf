# ------------------------------------------------------------------------------
# service-onboarding - register a new service on the shared LB.
#
# Creates exactly: a DNS A record, a backend of the requested type, and a
# backend service wrapping it. The URL-map host rule is exposed as an output
# that the shared gxlb module consumes. This module deliberately does NOT
# expose any cert-creation inputs: the only way to serve HTTPS through it is
# via the shared cert map.
# ------------------------------------------------------------------------------

resource "google_dns_record_set" "a" {
  project      = var.project_id
  managed_zone = var.dns_zone_name
  name         = "${var.hostname}."
  type         = "A"
  ttl          = 300
  rrdatas      = [var.shared_lb_ip]
}

resource "google_compute_region_network_endpoint_group" "cloud_run" {
  count = var.backend_type == "cloud_run" ? 1 : 0

  project               = var.project_id
  name                  = "${var.name}-cr-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.backend_ref
  }
}

resource "google_compute_global_network_endpoint_group" "internet" {
  count = var.backend_type == "internet_neg" ? 1 : 0

  project               = var.project_id
  name                  = "${var.name}-inet-neg"
  network_endpoint_type = "INTERNET_FQDN_PORT"
}

resource "google_compute_backend_bucket" "bucket" {
  count = var.backend_type == "backend_bucket" ? 1 : 0

  project     = var.project_id
  name        = "${var.name}-bucket-backend"
  bucket_name = var.backend_ref
  enable_cdn  = false
}

locals {
  backend_id = {
    "cloud_run"      = var.backend_type == "cloud_run" ? google_compute_region_network_endpoint_group.cloud_run[0].id : ""
    "internet_neg"   = var.backend_type == "internet_neg" ? google_compute_global_network_endpoint_group.internet[0].id : ""
    "backend_bucket" = var.backend_type == "backend_bucket" ? google_compute_backend_bucket.bucket[0].id : ""
    "gke_neg"        = var.backend_type == "gke_neg" ? var.backend_ref : ""
  }[var.backend_type]
}

resource "google_compute_backend_service" "this" {
  count = var.backend_type != "backend_bucket" ? 1 : 0

  project               = var.project_id
  name                  = "${var.name}-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"

  backend {
    group = local.backend_id
  }

  labels = merge(var.common_labels, {
    service     = var.name
    environment = var.environment
    managed_by  = "service-onboarding-module"
  })
}
