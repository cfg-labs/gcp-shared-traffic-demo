package main

# Block per-service ManagedCertificate and self-managed SSL certs outside the
# dedicated modules. Every onboarding MUST go through service-onboarding, which
# reuses the shared wildcard cert via the cert map.

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "google_compute_managed_ssl_certificate"
  not startswith(resource.address, "module.")
  msg := sprintf(
    "Per-service managed cert '%s' is not allowed. Onboard via the service-onboarding module.",
    [resource.address]
  )
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "google_certificate_manager_certificate"
  resource.change.actions[_] == "create"
  not contains(resource.address, "module.shared_certs")
  not contains(resource.address, "module.private_ca")
  msg := sprintf(
    "Certificate Manager cert '%s' created outside shared_certs or private_ca modules. Reuse existing wildcard.",
    [resource.address]
  )
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "google_compute_global_forwarding_rule"
  resource.change.actions[_] == "create"
  not contains(resource.address, "module.gxlb")
  not contains(resource.address, "module.private_ca_lb")
  msg := sprintf(
    "New global forwarding rule '%s' outside shared LB modules. Use service-onboarding instead.",
    [resource.address]
  )
}
