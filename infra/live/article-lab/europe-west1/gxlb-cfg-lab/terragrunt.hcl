include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/gxlb.hcl"
}

dependency "certs" {
  config_path = "../certs-cfg-lab"

  mock_outputs = {
    certificate_ids = {
      "cfg-lab-wildcard" = "mock"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  name                = "cfg-lab"
  backend_bucket_name = "cfg-lab-demo-labs-491519"

  certificate_ids = {
    "primary-wildcard" = {
      certificate_id = dependency.certs.outputs.certificate_ids["cfg-lab-wildcard"]
      hostname       = null # PRIMARY fallback
    }
    "food-wildcard" = {
      certificate_id = dependency.certs.outputs.certificate_ids["cfg-lab-wildcard"]
      hostname       = "food.cfg-lab.computingforgeeks.com"
    }
    "admin-wildcard" = {
      certificate_id = dependency.certs.outputs.certificate_ids["cfg-lab-wildcard"]
      hostname       = "admin.cfg-lab.computingforgeeks.com"
    }
    "api-wildcard" = {
      certificate_id = dependency.certs.outputs.certificate_ids["cfg-lab-wildcard"]
      hostname       = "api.cfg-lab.computingforgeeks.com"
    }
  }

  host_rules = {
    "food"  = { hosts = ["food.cfg-lab.computingforgeeks.com"] }
    "admin" = { hosts = ["admin.cfg-lab.computingforgeeks.com"] }
    "api"   = { hosts = ["api.cfg-lab.computingforgeeks.com"] }
  }
}
