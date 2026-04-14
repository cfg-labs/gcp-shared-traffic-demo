include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/gke.hcl"
}

inputs = {
  cluster_name = "cfg-lab-gke"

  # Override any defaults here per-article. For example:
  # release_channel = "RAPID"  # if the article tests a bleeding-edge K8s version
  # enable_private_nodes = false  # if the article demo doesn't need private nodes
}
