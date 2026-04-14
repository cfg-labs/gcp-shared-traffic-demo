#!/usr/bin/env bash
# demo-rotate.sh - zero-incident cert rotation demo for the capstone (Article 10).
#
# Starts a traffic generator at 10 RPS per host, executes a blue-green swap of
# the shared LB's target HTTPS proxy onto a rotated cert, then analyzes the
# output. Expected result: zero non-2xx responses during the swap window.

set -euo pipefail

DURATION="${DURATION:-600s}"
RPS="${RPS:-10}"
OUTPUT="${OUTPUT:-/tmp/rotate-$(date +%Y%m%d-%H%M%S).json}"
INFRA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../infra" && pwd)"

HOSTS=(
  "food.cfg-lab.computingforgeeks.com"
  "admin.cfg-lab.computingforgeeks.com"
  "api.cfg-lab.computingforgeeks.com"
)

echo "== Starting traffic generator =="
"$(dirname "${BASH_SOURCE[0]}")/traffic-gen" \
  --duration="${DURATION}" \
  --rps="${RPS}" \
  --output="${OUTPUT}" \
  "${HOSTS[@]}" &
TG_PID=$!

echo "== Blue-green: building replacement target proxy =="
cd "${INFRA_ROOT}/live/article-lab/europe-west1/gxlb-cfg-lab"
terragrunt apply -auto-approve -var="enable_blue_green=true"

echo "== Waiting for replacement proxy to be healthy =="
sleep 30

echo "== Flipping forwarding-rule target to v2 =="
terragrunt apply -auto-approve -var="forwarding_rule_target=v2"

echo "== Soaking for TLS session drain =="
sleep 120

echo "== Destroying old target proxy =="
terragrunt apply -auto-approve -var="enable_blue_green=false"

echo "== Stopping traffic generator =="
kill "${TG_PID}" || true
wait "${TG_PID}" || true

echo "== Analyzing ${OUTPUT} =="
python3 "$(dirname "${BASH_SOURCE[0]}")/analyze-rotation.py" "${OUTPUT}"
