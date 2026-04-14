include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/dns-delegated-zone.hcl"
}

inputs = {
  zone_name                 = "cfg-lab"
  dns_name                  = "cfg-lab.computingforgeeks.com."
  cloudflare_ns_record_name = "cfg-lab"
  description               = "cert+DNS consolidation series — primary delegated subzone for all non-regional services"
}
