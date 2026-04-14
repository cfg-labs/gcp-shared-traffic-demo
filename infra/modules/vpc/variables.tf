variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_labels" {
  type    = map(string)
  default = {}
}

variable "name" {
  type    = string
  default = "cfg-lab-vpc"
}

variable "routing_mode" {
  type    = string
  default = "REGIONAL"
}

variable "auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "subnet_name" {
  type    = string
  default = "cfg-lab-subnet"
}

variable "subnet_cidr" {
  type    = string
  default = "10.42.0.0/20"
}

variable "pods_range_name" {
  type    = string
  default = "pods"
}

variable "pods_cidr" {
  type    = string
  default = "10.43.0.0/16"
}

variable "services_range_name" {
  type    = string
  default = "services"
}

variable "services_cidr" {
  type    = string
  default = "10.44.0.0/20"
}

variable "enable_cloud_nat" {
  type    = bool
  default = true
}

variable "enable_private_google_access" {
  type    = bool
  default = true
}
