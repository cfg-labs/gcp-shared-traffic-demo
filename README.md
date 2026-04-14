# gcp-shared-traffic-demo

Companion code for the **GCP Certificate, DNS & Traffic Consolidation** series on [computingforgeeks.com](https://computingforgeeks.com/).

The series walks a platform-engineering scenario end-to-end: a multi-service GCP organisation consolidates dozens of per-service TLS certificates and load balancers onto a small wildcard + Certificate Map set, isolates regulated workloads onto a Private CA chain, and drives the whole thing with GitOps and Terraform.

Every article in the series maps to a tagged release in this repository. Check out the tag to reproduce the article's exact state.

## Articles and tags

| Article | Tag | What this repo state contains |
|---|---|---|
| 1. The Certificate Sprawl Problem in GCP | `article-01` | 3 hello-world services on GKE Autopilot, each with its own ManagedCertificate + Ingress + static IP |
| 2. Cloud DNS with DNSSEC and CAA Records | `article-02` | Delegated subzone in Cloud DNS with DNSSEC on, CAA records, DS at registrar |
| 3. Certificate Manager + DNS Authorization Wildcards | `article-03` | Wildcard + apex Google-managed cert issued via DNS-01 |
| 4. Certificate Maps, Shared LB, and the Terraform Swap Trap | `article-04` | Shared Global External HTTPS LB replacing the per-service LBs, HSTS header, sub-subdomain handling |
| 5. Migrating from GKE Ingress to Gateway API | `article-05` | Services reattached via Gateway API + HTTPRoute with the shared wildcard |
| 6. Regional vs Global External ALB | `article-06` | Regional ALB demo in europe-west1 |
| 7. Private CA + Separate Financial LB | `article-07` | CA Service pool (DevOps tier) issuing a dedicated cert, second LB, custom trust chain |
| 8. SPKI Pinning Against a GCP Private CA | `article-08` | Python client with primary + backup pin, rotation demo |
| 9. Cert Inventory Terraform Module + ArgoCD | `article-09` | `service-onboarding` module, ArgoCD-managed HTTPRoute layer, Conftest policy blocking per-service certs |
| 10. Full Demo App + Zero-Incident Rotation | `article-10` | Online Boutique running end-to-end across all infra, live rotation demo with traffic generator |
| 11. Monitoring, Runbook, Migration Playbook | `article-11` | Cert expiration + ACME failure alerts, uptime checks, runbook suite |

## Repository layout

```
.
├── infra/        # Terragrunt live stacks + reusable modules
├── apps/         # Workload manifests (Online Boutique + payment demo)
├── argocd/       # App-of-apps, per-service Application CRs
├── clients/      # SPKI-pinned Python client
└── scripts/      # audit-certs.sh, session-up.sh, session-down.sh
```

## Quickstart

Prerequisites: an empty GCP project, OpenTofu (or Terraform), Terragrunt, gcloud, kubectl, and a domain delegated to Cloud DNS.

```
make bootstrap   # DNS zone delegation + state bucket
make up          # build the full lab (GKE Autopilot, shared LB, cert map)
make demo        # deploy the Online Boutique workloads via ArgoCD
make rotate      # execute the zero-incident rotation with traffic generator
make down        # destroy everything, verify clean
```

## Licence

MIT. See [LICENSE](LICENSE).

## Feedback

Issues and PRs welcome. Long-form walkthroughs live on [computingforgeeks.com](https://computingforgeeks.com/) — the repo is the runnable complement, not a replacement for the articles.
