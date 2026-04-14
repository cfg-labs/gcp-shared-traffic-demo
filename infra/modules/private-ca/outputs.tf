output "pool_name" {
  value       = google_privateca_ca_pool.this.name
  description = "CA pool name (used by clients issuing certs)"
}

output "pool_location" {
  value = google_privateca_ca_pool.this.location
}

output "root_ca_name" {
  value = google_privateca_certificate_authority.root.certificate_authority_id
}

output "root_ca_pem" {
  value       = google_privateca_certificate_authority.root.pem_ca_certificates
  description = "Root CA public cert chain (distribute to clients for trust)"
}
