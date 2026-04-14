include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/certificate-manager.hcl"
}

dependency "dns" {
  config_path = "../dns-cfg-regional"
  mock_outputs = {
    zone_name = "cfg-regional"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  location      = "europe-west1"
  dns_zone_name = dependency.dns.outputs.zone_name

  dns_auth_domains = {
    regional = "cfg-regional.computingforgeeks.com"
  }

  certificates = {
    "cfg-regional-wildcard" = {
      domains       = ["*.cfg-regional.computingforgeeks.com", "cfg-regional.computingforgeeks.com"]
      dns_auth_keys = ["regional"]
    }
  }
}
