# ------------------------------------------------------------------------------
# certificate-manager — Google-managed certs via DNS-01 authorization
#
# One DNS authorization per apex domain; one CNAME per authorization placed
# in the delegated Cloud DNS zone. Certs reference one or more authorizations
# and can cover wildcard + apex in a single cert.
# ------------------------------------------------------------------------------

resource "google_certificate_manager_dns_authorization" "this" {
  for_each = var.dns_auth_domains

  project     = var.project_id
  name        = "dns-auth-${each.key}"
  location    = var.location
  domain      = each.value
  description = "DNS-01 authorization for ${each.value}"
  labels      = var.common_labels
}

# ACME CNAME placed in the delegated Cloud DNS zone so Google Trust Services
# can prove domain control during cert issuance and renewal.
resource "google_dns_record_set" "acme_cname" {
  for_each = google_certificate_manager_dns_authorization.this

  project      = var.project_id
  managed_zone = var.dns_zone_name
  name         = each.value.dns_resource_record[0].name
  type         = each.value.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [each.value.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "this" {
  for_each = var.certificates

  project     = var.project_id
  name        = each.key
  location    = var.location
  description = "Managed cert: ${join(", ", each.value.domains)}"
  labels      = var.common_labels

  managed {
    domains = each.value.domains
    dns_authorizations = [
      for k in each.value.dns_auth_keys :
      google_certificate_manager_dns_authorization.this[k].id
    ]
  }

  depends_on = [google_dns_record_set.acme_cname]
}
