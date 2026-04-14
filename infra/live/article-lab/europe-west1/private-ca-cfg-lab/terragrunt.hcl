include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/modules/private-ca"
}

inputs = {
  location     = "europe-west1"
  pool_name    = "cfg-lab-devops-pool"
  pool_tier    = "DEVOPS"
  root_ca_name = "cfg-lab-root-ca"

  root_ca_subject = {
    common_name  = "CFG Lab Root CA"
    organization = "ComputingForGeeks Lab"
    country_code = "US"
  }

  root_ca_validity = "P10Y"
}
