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

variable "cluster_name" {
  type    = string
  default = "cfg-lab-gke"
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "pods_range_name" {
  type    = string
  default = "pods"
}

variable "services_range_name" {
  type    = string
  default = "services"
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "enable_private_nodes" {
  type    = bool
  default = true
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "deletion_protection" {
  type    = bool
  default = false
}
