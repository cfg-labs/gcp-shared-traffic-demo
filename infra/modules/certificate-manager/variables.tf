variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Certificate Manager location: 'global' for global LBs, region name for regional"
  type        = string
  default     = "global"
}

variable "dns_zone_name" {
  description = "Google Cloud DNS managed zone name that holds the ACME CNAME records"
  type        = string
}

variable "dns_auth_domains" {
  description = "Map of logical name -> apex domain to authorize (e.g. { lab = \"cfg-lab.computingforgeeks.com\" })"
  type        = map(string)
}

variable "certificates" {
  description = "Map of cert name -> { domains = list(string), dns_auth_keys = list(string) }"
  type = map(object({
    domains       = list(string)
    dns_auth_keys = list(string)
  }))
  default = {}
}

variable "common_labels" {
  description = "Labels applied to every Certificate Manager resource"
  type        = map(string)
  default     = {}
}
