# ------------------------------------------------------------------------------
# dns-delegated-zone — inputs
# ------------------------------------------------------------------------------

variable "project_id" {
  type        = string
  description = "GCP project hosting the Cloud DNS zone."
}

variable "region" {
  type        = string
  description = "Unused for this global resource. Required to match root terragrunt input contract."
  default     = "global"
}

variable "environment" {
  type    = string
  default = "article-lab"
}

variable "common_labels" {
  type    = map(string)
  default = {}
}

variable "zone_name" {
  type        = string
  description = "Cloud DNS managed_zone resource name (hyphen-separated, e.g. cfg-lab)."
}

variable "dns_name" {
  type        = string
  description = "The fully-qualified DNS name for the zone, trailing dot required (e.g. cfg-lab.computingforgeeks.com.)."
}

variable "description" {
  type    = string
  default = "Article-lab delegated subzone managed by Terraform"
}

variable "enable_dnssec" {
  type    = bool
  default = true
}

variable "caa_issuers" {
  type        = list(string)
  description = "CAs authorized to issue non-wildcard certs for this zone."
  default     = ["pki.goog"]
}

variable "caa_wildcard_issuers" {
  type        = list(string)
  description = "CAs authorized to issue wildcard certs for this zone."
  default     = ["pki.goog"]
}

variable "caa_iodef_email" {
  type        = string
  description = "Email address for CA issuance violation reports."
  default     = "security@computingforgeeks.com"
}

variable "cloudflare_parent_zone_id" {
  type        = string
  description = "Cloudflare zone ID of the parent domain (e.g. computingforgeeks.com)."
}

variable "cloudflare_ns_record_name" {
  type        = string
  description = "Relative name of the delegation at the parent (e.g. cfg-lab for cfg-lab.computingforgeeks.com)."
}
