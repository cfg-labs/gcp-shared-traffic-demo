# _envcommon/vpc.hcl — shared VPC stack definition for GCP

terraform {
  source = "${dirname(find_in_parent_folders())}/modules/vpc"
}

inputs = {
  name               = "cfg-lab-vpc"
  routing_mode       = "REGIONAL"
  auto_create_subnetworks = false

  # Subnet defaults for article testing
  subnet_name        = "cfg-lab-subnet"
  subnet_cidr        = "10.42.0.0/20"

  # Secondary ranges for GKE pods and services
  pods_range_name    = "pods"
  pods_cidr          = "10.43.0.0/16"
  services_range_name = "services"
  services_cidr      = "10.44.0.0/20"

  # Cloud NAT for private nodes to reach the internet
  enable_cloud_nat   = true

  # Private Google Access so GKE nodes pull images without Cloud NAT data processing
  enable_private_google_access = true
}
