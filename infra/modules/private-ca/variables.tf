variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "CA Service region"
  type        = string
  default     = "europe-west1"
}

variable "pool_name" {
  description = "CA pool name"
  type        = string
}

variable "pool_tier" {
  description = "CA pool tier: DEVOPS (lab) or ENTERPRISE (production)"
  type        = string
  default     = "DEVOPS"
}

variable "root_ca_name" {
  description = "Root CA name within the pool"
  type        = string
}

variable "root_ca_subject" {
  description = "X.509 subject for the root CA"
  type = object({
    common_name         = string
    organization        = string
    organizational_unit = optional(string, "")
    country_code        = string
  })
}

variable "root_ca_validity" {
  description = "Root CA validity in ISO 8601 duration format"
  type        = string
  default     = "P10Y"
}

variable "common_labels" {
  description = "Labels applied to CA resources that accept them"
  type        = map(string)
  default     = {}
}
