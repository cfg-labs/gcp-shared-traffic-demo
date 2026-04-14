output "zone_name" {
  value       = google_dns_managed_zone.this.name
  description = "Cloud DNS managed zone resource name."
}

output "dns_name" {
  value       = google_dns_managed_zone.this.dns_name
  description = "FQDN of the zone, trailing dot included."
}

output "name_servers" {
  value       = google_dns_managed_zone.this.name_servers
  description = "The 4 Google Cloud DNS nameservers assigned to this zone."
}

output "dnssec_ds_record_value" {
  value       = try(google_dns_managed_zone.this.dnssec_config[0].default_key_specs, null)
  description = "Raw DNSSEC key specs. Use 'gcloud dns dns-keys list' to pull the exact DS rdata for submission at the registrar."
  sensitive   = false
}
