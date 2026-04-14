# ------------------------------------------------------------------------------
# private-ca - CA Service pool + root CA for financial-services isolation.
#
# Creates a single-tier hierarchy (root CA directly in the pool). For production
# add a subordinate CA below the root. DevOps-tier pools have no standing charge
# and are the right default for article labs.
# ------------------------------------------------------------------------------

resource "google_privateca_ca_pool" "this" {
  project  = var.project_id
  name     = var.pool_name
  location = var.location
  tier     = var.pool_tier
  labels   = var.common_labels

  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}

resource "google_privateca_certificate_authority" "root" {
  project                  = var.project_id
  pool                     = google_privateca_ca_pool.this.name
  certificate_authority_id = var.root_ca_name
  location                 = var.location
  type                     = "SELF_SIGNED"
  labels                   = var.common_labels

  config {
    subject_config {
      subject {
        common_name         = var.root_ca_subject.common_name
        organization        = var.root_ca_subject.organization
        organizational_unit = var.root_ca_subject.organizational_unit
        country_code        = var.root_ca_subject.country_code
      }
    }
    x509_config {
      ca_options {
        is_ca = true
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {
          server_auth = true
          client_auth = true
        }
      }
    }
  }

  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }

  lifetime               = var.root_ca_validity == "P10Y" ? "${10 * 365 * 24 * 60 * 60}s" : var.root_ca_validity
  deletion_protection    = false
  skip_grace_period      = true
  ignore_active_certificates_on_deletion = true
}
