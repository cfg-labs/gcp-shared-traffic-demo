terraform {
  source = "${dirname(find_in_parent_folders())}/modules/certificate-manager"
}

inputs = {
  location = "global"
}
