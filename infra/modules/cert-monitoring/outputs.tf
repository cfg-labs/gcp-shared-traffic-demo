output "alert_policy_ids" {
  value = {
    for k, p in google_monitoring_alert_policy.cert_expiry : k => p.id
  }
}

output "acme_failure_metric_name" {
  value = google_logging_metric.acme_challenge_failures.name
}

output "uptime_check_names" {
  value = { for k, u in google_monitoring_uptime_check_config.hostname : k => u.uptime_check_id }
}
