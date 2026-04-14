#!/usr/bin/env bash
# audit-certs.sh - cross-project cert inventory for the fleet.
#
# Lists every cert in every project the caller can read. Output is CSV to stdout:
# project,type,name,state/status,sans

set -euo pipefail

echo "project,type,name,state,sans"

for PROJECT in $(gcloud projects list --format="value(projectId)"); do
  # Compute Engine classic SSL certs (deprecated but still common)
  gcloud compute ssl-certificates list --project="${PROJECT}" \
    --format="csv[no-heading](name,type,managed.status,subjectAlternativeNames.flatten(separator='|'))" 2>/dev/null \
    | awk -F, -v p="${PROJECT}" '{print p",compute_ssl,"$1","$3","$4}' || true

  # Certificate Manager
  gcloud certificate-manager certificates list --project="${PROJECT}" \
    --format="csv[no-heading](name.basename(),location.basename(),managed.state,managed.domains.flatten(separator='|'))" 2>/dev/null \
    | awk -F, -v p="${PROJECT}" '{print p",cert_manager_"$2","$1","$3","$4}' || true

  # Private CA certs are not enumerable per-cert in DevOps tier; list the CAs instead
  gcloud privateca pools list --project="${PROJECT}" --format="value(name,tier,location)" 2>/dev/null \
    | while read -r pool tier loc; do
        echo "${PROJECT},private_ca_pool,${pool},${tier},${loc}"
      done || true
done
