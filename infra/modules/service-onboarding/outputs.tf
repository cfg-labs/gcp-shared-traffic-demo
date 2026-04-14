output "hostname" {
  value = var.hostname
}

output "url_map_host_rule" {
  description = "Host-rule stub to merge into the shared gxlb URL map"
  value = {
    hosts        = [var.hostname]
    path_matcher = var.name
    service_id = var.backend_type == "backend_bucket" ? google_compute_backend_bucket.bucket[0].id : google_compute_backend_service.this[0].id
  }
}

output "dns_record" {
  value = google_dns_record_set.a.name
}
