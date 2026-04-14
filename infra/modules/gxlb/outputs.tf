output "ip_address" {
  value       = google_compute_global_address.this.address
  description = "Public anycast IP of the LB"
}

output "url_map_id" {
  value = google_compute_url_map.this.id
}

output "target_proxy_id" {
  value = google_compute_target_https_proxy.this.id
}

output "cert_map_id" {
  value = google_certificate_manager_certificate_map.this.id
}

output "forwarding_rule_name" {
  value = google_compute_global_forwarding_rule.https.name
}
