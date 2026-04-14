#!/usr/bin/env bash
# session-down.sh - tear down every series stack in reverse dependency order.

set -euo pipefail

PROJECT_ID="${PROJECT_ID:-labs-491519}"
REGION="${REGION:-europe-west1}"
INFRA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../infra" && pwd)"

STACKS_REVERSE=(
  "private-ca-cfg-lab"
  "gxlb-cfg-lab"
  "certs-cfg-regional"
  "certs-cfg-lab"
  "dns-cfg-regional"
  "dns-cfg-lab"
)

for stack in "${STACKS_REVERSE[@]}"; do
  dir="${INFRA_ROOT}/live/article-lab/${REGION}/${stack}"
  if [ -d "${dir}" ]; then
    echo "== Destroying ${stack} =="
    cd "${dir}"
    terragrunt destroy -auto-approve || echo "WARN: ${stack} destroy returned non-zero; continuing"
  fi
done

echo "== Running validate-clean =="
"${INFRA_ROOT}/../scripts/validate-clean.sh" || true
