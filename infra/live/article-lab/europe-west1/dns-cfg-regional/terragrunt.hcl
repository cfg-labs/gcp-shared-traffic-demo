include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/live/_envcommon/dns-delegated-zone.hcl"
}

inputs = {
  zone_name                 = "cfg-regional"
  dns_name                  = "cfg-regional.computingforgeeks.com."
  cloudflare_ns_record_name = "cfg-regional"
  description               = "cert+DNS consolidation series — regional delegated subzone (regional ALB demo)"
}
