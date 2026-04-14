#!/usr/bin/env bash
# session-up.sh - provision every series stack in dependency order.
#
# Requires: gcloud (authenticated), tofu/terraform, terragrunt, kubectl, CF_API_TOKEN env var.

set -euo pipefail

PROJECT_ID="${PROJECT_ID:-labs-491519}"
REGION="${REGION:-europe-west1}"
INFRA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../infra" && pwd)"

echo "== Enabling required APIs =="
gcloud services enable \
  dns.googleapis.com \
  certificatemanager.googleapis.com \
  privateca.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  --project="${PROJECT_ID}"

echo "== Applying foundational DNS zones =="
cd "${INFRA_ROOT}/live/article-lab/${REGION}/dns-cfg-lab"
terragrunt apply -auto-approve

cd "${INFRA_ROOT}/live/article-lab/${REGION}/dns-cfg-regional"
terragrunt apply -auto-approve

echo "== Applying Certificate Manager certs =="
cd "${INFRA_ROOT}/live/article-lab/${REGION}/certs-cfg-lab"
terragrunt apply -auto-approve

cd "${INFRA_ROOT}/live/article-lab/${REGION}/certs-cfg-regional"
terragrunt apply -auto-approve

echo "== Applying shared GXLB =="
cd "${INFRA_ROOT}/live/article-lab/${REGION}/gxlb-cfg-lab"
terragrunt apply -auto-approve

echo "== Applying Private CA =="
cd "${INFRA_ROOT}/live/article-lab/${REGION}/private-ca-cfg-lab"
terragrunt apply -auto-approve

echo "== All stacks applied. Run 'make argocd' next to install ArgoCD on the cluster. =="
