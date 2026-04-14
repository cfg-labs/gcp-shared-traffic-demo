# _envcommon/dns-delegated-zone.hcl — shared config for every delegated-subzone stack.
#
# Reads CLOUDFLARE_API_TOKEN from the environment at apply time. The helper
# script scripts/load-env.sh exports it from .env.

terraform {
  source = "${dirname(find_in_parent_folders())}/modules/dns-delegated-zone"
}

generate "cloudflare_provider" {
  path      = "cloudflare_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "cloudflare" {
  # api_token sourced from CLOUDFLARE_API_TOKEN env var
}
EOF
}

inputs = {
  # Computingforgeeks.com zone ID in Cloudflare (from .claude/rules/ssl-mandatory.md).
  cloudflare_parent_zone_id = "5a8e1ae43e23cfecdd02bd835f919472"

  # CAA: Google Trust Services for wildcards, Let's Encrypt kept in the allow-list
  # because the parent domain uses it for per-article VM certs.
  caa_issuers          = ["pki.goog", "letsencrypt.org"]
  caa_wildcard_issuers = ["pki.goog"]
  caa_iodef_email      = "security@computingforgeeks.com"
}
