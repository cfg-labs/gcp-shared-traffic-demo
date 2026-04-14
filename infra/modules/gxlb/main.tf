# ------------------------------------------------------------------------------
# gxlb — Global External HTTPS LB with Certificate Manager cert map.
#
# Pattern: one LB, one cert map, N cert map entries (one per hostname).
# Backend is a single backend-bucket wired to an existing GCS bucket so the
# article can demonstrate the LB pattern without provisioning GKE/MIGs.
# HSTS is set as a custom response header on the backend bucket.
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "this" {
  project = var.project_id
  name    = "${var.name}-ip"
}

resource "google_compute_backend_bucket" "this" {
  project     = var.project_id
  name        = "${var.name}-backend"
  description = "Default backend for ${var.name}"
  bucket_name = var.backend_bucket_name
  enable_cdn  = false

  custom_response_headers = var.hsts_header == "" ? [] : [
    "Strict-Transport-Security: ${var.hsts_header}",
  ]
}

resource "google_compute_url_map" "this" {
  project         = var.project_id
  name            = var.name
  default_service = google_compute_backend_bucket.this.id

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.key
    }
  }

  dynamic "path_matcher" {
    for_each = var.host_rules
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_bucket.this.id
    }
  }
}

resource "google_certificate_manager_certificate_map" "this" {
  project     = var.project_id
  name        = "${var.name}-cert-map"
  description = "Cert map for ${var.name}"
  labels      = var.common_labels
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  for_each = var.certificate_ids

  project      = var.project_id
  name         = each.key
  description  = "Cert map entry for ${coalesce(each.value.hostname, "PRIMARY fallback")}"
  map          = google_certificate_manager_certificate_map.this.name
  certificates = [each.value.certificate_id]
  labels       = var.common_labels

  hostname = each.value.hostname
  matcher  = each.value.hostname == null ? "PRIMARY" : null
}

resource "google_compute_target_https_proxy" "this" {
  project = var.project_id
  name    = "${var.name}-https-proxy"
  url_map = google_compute_url_map.this.id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.this.id}"

  depends_on = [google_certificate_manager_certificate_map_entry.this]
}

resource "google_compute_global_forwarding_rule" "https" {
  project               = var.project_id
  name                  = "${var.name}-https"
  target                = google_compute_target_https_proxy.this.id
  port_range            = "443"
  ip_address            = google_compute_global_address.this.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
  labels                = var.common_labels
}
