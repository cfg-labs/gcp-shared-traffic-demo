variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Service name (used as the URL-map path matcher and backend-service prefix)"
  type        = string
}

variable "hostname" {
  description = "FQDN to register for this service (e.g. market.cfg-lab.computingforgeeks.com)"
  type        = string
}

variable "dns_zone_name" {
  description = "Cloud DNS managed zone name that hosts the hostname"
  type        = string
}

variable "shared_lb_ip" {
  description = "Shared LB's public anycast IP (output of the gxlb module)"
  type        = string
}

variable "backend_type" {
  description = "Backend kind: cloud_run | gke_neg | internet_neg | backend_bucket"
  type        = string
  validation {
    condition     = contains(["cloud_run", "gke_neg", "internet_neg", "backend_bucket"], var.backend_type)
    error_message = "backend_type must be one of: cloud_run, gke_neg, internet_neg, backend_bucket"
  }
}

variable "backend_ref" {
  description = "Reference to the existing backend (Cloud Run service name, GKE NEG self-link, etc.)"
  type        = string
}

variable "region" {
  description = "Region for regional backends (cloud_run, gke_neg)"
  type        = string
  default     = "europe-west1"
}

variable "environment" {
  description = "Environment label applied to every produced resource"
  type        = string
}

variable "common_labels" {
  description = "Extra labels merged into every resource that accepts labels"
  type        = map(string)
  default     = {}
}
