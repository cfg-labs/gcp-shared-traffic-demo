variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Base name for every LB resource"
  type        = string
}

variable "certificate_ids" {
  description = "Certificate Manager certificate IDs attached via cert map entries"
  type = map(object({
    certificate_id = string
    hostname       = optional(string) # null for PRIMARY entry
  }))
}

variable "backend_bucket_name" {
  description = "Existing GCS bucket name to wire up as default backend"
  type        = string
}

variable "host_rules" {
  description = "Map of logical rule name -> { hosts = list(string) }. Each rule routes to the shared backend bucket."
  type = map(object({
    hosts = list(string)
  }))
  default = {}
}

variable "hsts_header" {
  description = "Strict-Transport-Security header value. Empty string disables."
  type        = string
  default     = "max-age=31536000; includeSubDomains; preload"
}

variable "common_labels" {
  description = "Labels applied to LB resources that accept labels"
  type        = map(string)
  default     = {}
}
