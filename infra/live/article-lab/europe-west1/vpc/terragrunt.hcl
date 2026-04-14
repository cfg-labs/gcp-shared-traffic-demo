include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/vpc.hcl"
}

inputs = {
  # Override defaults here per-article if needed.
  # name        = "cfg-lab-vpc"   # already set in envcommon
  # subnet_cidr = "10.42.0.0/20"  # already set in envcommon
}
