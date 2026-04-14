# ------------------------------------------------------------------------------
# dns-delegated-zone — creates a Google Cloud DNS managed zone with DNSSEC +
# CAA, and delegates it from a Cloudflare-hosted parent domain via 4 NS records.
#
# One-shot apply produces a functional, DNSSEC-on delegated subzone. The DS
# record for DNSSEC chain-of-trust is added in a follow-up stack once the
# KSK is stable (the dns_name_servers can resolve before DS exists; DS just
# enables validation).
# ------------------------------------------------------------------------------

resource "google_dns_managed_zone" "this" {
  project       = var.project_id
  name          = var.zone_name
  dns_name      = var.dns_name
  description   = var.description
  visibility    = "public"
  labels        = var.common_labels

  dynamic "dnssec_config" {
    for_each = var.enable_dnssec ? [1] : []
    content {
      state         = "on"
      non_existence = "nsec3"
      default_key_specs {
        algorithm  = "rsasha256"
        key_type   = "keySigning"
        key_length = 2048
      }
      default_key_specs {
        algorithm  = "rsasha256"
        key_type   = "zoneSigning"
        key_length = 1024
      }
    }
  }
}

# CAA record restricting issuance to approved CAs.
resource "google_dns_record_set" "caa" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.this.name
  name         = var.dns_name
  type         = "CAA"
  ttl          = 3600

  rrdatas = concat(
    [for ca in var.caa_issuers : "0 issue \"${ca}\""],
    [for ca in var.caa_wildcard_issuers : "0 issuewild \"${ca}\""],
    ["0 iodef \"mailto:${var.caa_iodef_email}\""],
  )
}

# Delegation at the parent (Cloudflare). Four NS records pointing at the GCP
# nameservers that Cloud DNS assigned to the new zone.
# Google Cloud DNS always returns exactly 4 nameservers; hardcode to 4 so
# count is known at plan time.
resource "cloudflare_record" "ns_delegation" {
  count = 4

  zone_id = var.cloudflare_parent_zone_id
  name    = var.cloudflare_ns_record_name
  type    = "NS"
  content = google_dns_managed_zone.this.name_servers[count.index]
  ttl     = 3600
  proxied = false
  comment = "Delegation to Google Cloud DNS (labs-491519) managed by Terraform"
}
