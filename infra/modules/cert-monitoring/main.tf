# ------------------------------------------------------------------------------
# cert-monitoring - expiry alerts, ACME failure log metric, uptime checks.
# ------------------------------------------------------------------------------

locals {
  expiry_thresholds = {
    "60d" = 60 * 24 * 60 * 60
    "30d" = 30 * 24 * 60 * 60
    "7d"  = 7 * 24 * 60 * 60
  }
}

resource "google_monitoring_alert_policy" "cert_expiry" {
  for_each = local.expiry_thresholds

  project      = var.project_id
  display_name = "Certificate Manager cert expiring in ${each.key}"
  combiner     = "OR"

  conditions {
    display_name = "Days-until-expiry under ${each.key}"
    condition_threshold {
      filter = join(" AND ", [
        "resource.type = \"certificatemanager.googleapis.com/Certificate\"",
        "metric.type = \"certificatemanager.googleapis.com/certificate/expiry_seconds\"",
      ])
      threshold_value = each.value
      comparison      = "COMPARISON_LT"
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MIN"
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "Runbook: ${var.runbook_url_base}/cert-rotation-general.md"
    mime_type = "text/markdown"
  }
}

resource "google_logging_metric" "acme_challenge_failures" {
  project = var.project_id
  name    = "cert_manager/acme_challenge_failures"

  filter = join(" AND ", [
    "resource.type = \"audited_resource\"",
    "protoPayload.serviceName = \"certificatemanager.googleapis.com\"",
    "protoPayload.response.managed.state = \"FAILED\"",
  ])

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "acme_failures" {
  project      = var.project_id
  display_name = "Certificate Manager ACME challenge failures"
  combiner     = "OR"

  conditions {
    display_name = "ACME FAILED events in last 5m > 0"
    condition_threshold {
      filter          = "metric.type = \"logging.googleapis.com/user/${google_logging_metric.acme_challenge_failures.name}\""
      threshold_value = 0
      comparison      = "COMPARISON_GT"
      duration        = "0s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "Runbook: ${var.runbook_url_base}/cert-rotation-general.md"
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_uptime_check_config" "hostname" {
  for_each = toset(var.monitored_hostnames)

  project      = var.project_id
  display_name = "HTTPS: ${each.key}"

  http_check {
    path         = "/"
    port         = 443
    use_ssl      = true
    validate_ssl = true

    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.project_id
    }
  }

  period           = "60s"
  timeout          = "10s"
  selected_regions = ["USA_OREGON", "EUROPE", "ASIA_PACIFIC"]
}
