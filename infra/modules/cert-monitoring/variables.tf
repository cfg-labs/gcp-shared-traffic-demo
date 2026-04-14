variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "notification_channels" {
  description = "Monitoring notification channel IDs (email, PagerDuty, etc.)"
  type        = list(string)
  default     = []
}

variable "runbook_url_base" {
  description = "Base URL of the runbook repo (used in alert documentation fields)"
  type        = string
  default     = "https://github.com/cfg-labs/gcp-shared-traffic-demo/blob/main/runbooks"
}

variable "monitored_hostnames" {
  description = "Hostnames to include in the uptime check set"
  type        = list(string)
  default     = []
}
