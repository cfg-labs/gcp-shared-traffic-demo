include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/certificate-manager.hcl"
}

dependency "dns" {
  config_path = "../dns-cfg-lab"

  mock_outputs = {
    zone_name = "cfg-lab"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  dns_zone_name = dependency.dns.outputs.zone_name

  dns_auth_domains = {
    lab = "cfg-lab.computingforgeeks.com"
  }

  certificates = {
    "cfg-lab-wildcard" = {
      domains       = ["*.cfg-lab.computingforgeeks.com", "cfg-lab.computingforgeeks.com"]
      dns_auth_keys = ["lab"]
    }
  }
}
