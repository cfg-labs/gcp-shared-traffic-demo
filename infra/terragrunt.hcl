# Root Terragrunt configuration for GCP article testing.
#
# Every stack under live/ inherits this file via `include { path = find_in_parent_folders() }`.
# It centralizes:
#   - Remote state backend (GCS)
#   - Google provider generation with consistent labels
#   - Common inputs available to every stack
#
# DO NOT put per-environment or per-stack values here. Those belong in:
#   - live/<env>/env.hcl         (environment-level: name, project, region)
#   - live/<env>/<region>/region.hcl (region-level: overrides if needed)
#   - live/<env>/<region>/<stack>/terragrunt.hcl (stack-level: direct inputs)

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.env_vars.locals.environment
  project_id  = local.env_vars.locals.project_id
  region      = local.region_vars.locals.region
  owner       = local.env_vars.locals.owner

  # Credentials file for the google provider.
  credentials_file = "/Users/jkmutai/Library/Mobile Documents/com~apple~CloudDocs/projects/c4geeks/labs-491519-50f0ffa27f95.json"

  # Single source of truth for labels on every GCP resource.
  common_labels = {
    environment  = local.environment
    managed_by   = "terragrunt"
    owner        = local.owner
    repo         = "c4geeks-infra-gcp"
    cost_center  = "article-testing"
  }
}

# ------------------------------------------------------------------------------
# Remote state — GCS
# ------------------------------------------------------------------------------
remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket      = "c4geeks-gcp-tfstate"
    prefix      = "${path_relative_to_include()}/terraform.tfstate"
    project     = local.project_id
    location    = "EU"
    credentials = local.credentials_file
  }
}

# ------------------------------------------------------------------------------
# Provider generation
# ------------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project     = "${local.project_id}"
  region      = "${local.region}"
  credentials = file("${local.credentials_file}")

  default_labels = ${jsonencode(local.common_labels)}
}

provider "google-beta" {
  project     = "${local.project_id}"
  region      = "${local.region}"
  credentials = file("${local.credentials_file}")

  default_labels = ${jsonencode(local.common_labels)}
}
EOF
}

# ------------------------------------------------------------------------------
# Version constraints
# ------------------------------------------------------------------------------
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.20"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52"
    }
  }
}
EOF
}

# ------------------------------------------------------------------------------
# Common inputs propagated to every stack
# ------------------------------------------------------------------------------
inputs = {
  project_id    = local.project_id
  region        = local.region
  environment   = local.environment
  common_labels = local.common_labels
}
