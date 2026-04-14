output "dns_authorization_ids" {
  description = "Map of auth key -> authorization resource ID"
  value       = { for k, a in google_certificate_manager_dns_authorization.this : k => a.id }
}

output "certificate_ids" {
  description = "Map of cert name -> certificate resource ID"
  value       = { for k, c in google_certificate_manager_certificate.this : k => c.id }
}

output "acme_cname_records" {
  description = "The CNAME records published for each DNS authorization (for documentation)"
  value = {
    for k, a in google_certificate_manager_dns_authorization.this :
    k => {
      name = a.dns_resource_record[0].name
      data = a.dns_resource_record[0].data
    }
  }
}
