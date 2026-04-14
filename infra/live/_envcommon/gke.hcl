# _envcommon/gke.hcl — shared GKE Autopilot stack definition

terraform {
  source = "${dirname(find_in_parent_folders())}/modules/gke-autopilot"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    network_name        = "cfg-lab-vpc"
    subnet_name         = "cfg-lab-subnet"
    pods_range_name     = "pods"
    services_range_name = "services"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

inputs = {
  cluster_name = "cfg-lab-gke"

  network_name        = dependency.vpc.outputs.network_name
  subnet_name         = dependency.vpc.outputs.subnet_name
  pods_range_name     = dependency.vpc.outputs.pods_range_name
  services_range_name = dependency.vpc.outputs.services_range_name

  # Default: Autopilot with regular release channel.
  # Workload Identity is always on for Autopilot.
  release_channel          = "REGULAR"
  enable_private_nodes     = true
  master_ipv4_cidr_block   = "172.16.0.0/28"
  deletion_protection      = false
}
