# gcp-shared-traffic-demo

Companion code for the **GCP Certificate, DNS & Traffic Consolidation** series on [computingforgeeks.com](https://computingforgeeks.com/category/gcp/).

The series walks a platform-engineering scenario end-to-end: a multi-service GCP organisation consolidates dozens of per-service TLS certificates and load balancers onto a small wildcard + Certificate Map set, isolates regulated workloads onto a Private CA chain, and drives the whole thing with GitOps and Terraform.

Every article in the series maps to a tagged release in this repository. Check out the tag to reproduce the article's exact state.

## Articles and tags

| # | Article | Tag | Repo state |
|---|---|---|---|
| 1 | [Audit GCP Certificate Sprawl on Per-Service ManagedCertificate](https://computingforgeeks.com/gcp-certificate-sprawl-per-service-managedcertificate/) | [`article-01`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-01) | 3 hello-world services on GKE Autopilot, each with its own ManagedCertificate + Ingress + static IP |
| 2 | [Configure Cloud DNS DNSSEC and CAA on GCP (Terraform)](https://computingforgeeks.com/gcp-cloud-dns-dnssec-caa-terraform/) | [`article-02`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-02) | Delegated subzones in Cloud DNS with DNSSEC + CAA + Cloudflare NS delegation |
| 3 | [Issue GCP Wildcard Certs with DNS Authorization (Terraform)](https://computingforgeeks.com/gcp-cert-manager-wildcard-dns-auth/) | [`article-03`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-03) | Wildcard + apex Google-managed cert issued via DNS-01 |
| 4 | [Consolidate GCP Certs on a Shared LB with Cert Maps](https://computingforgeeks.com/gcp-shared-lb-cert-map-swap/) | [`article-04`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-04) | Shared Global External HTTPS LB replacing per-service LBs, HSTS header, sub-subdomain handling |
| 5 | [Migrate GKE Ingress to Gateway API with Cert Manager](https://computingforgeeks.com/gke-gateway-api-cert-manager-migration/) | [`article-05`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-05) | Services reattached via Gateway API + HTTPRoute with the shared wildcard |
| 6 | [Choose GCP Regional vs Global External ALB](https://computingforgeeks.com/gcp-regional-vs-global-external-alb/) | [`article-06`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-06) | Regional Certificate Manager cert in europe-west1 for cfg-regional zone |
| 7 | [Deploy GCP Private CA for Financial Service Certs](https://computingforgeeks.com/gcp-private-ca-financial-services/) | [`article-07`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-07) | CA Service pool (DevOps tier) issuing a dedicated cert, separate LB pattern, custom trust chain |
| 8 | [Implement SPKI Cert Pinning for GCP Private CA](https://computingforgeeks.com/spki-pinning-gcp-private-ca/) | [`article-08`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-08) | Python client with primary + backup pin, rotation demo |
| 9 | [Enforce GCP Cert Consolidation with Terraform and ArgoCD](https://computingforgeeks.com/gcp-cert-inventory-terraform-argocd/) | [`article-09`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-09) | `service-onboarding` module, ArgoCD app-of-apps, Conftest policy blocking per-service certs |
| 10 | [Build a Zero-Incident Cert Rotation Demo on GCP](https://computingforgeeks.com/gcp-zero-incident-cert-rotation-demo/) | [`article-10`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-10) | Capstone scripts: `session-up`/`session-down`, traffic generator, `demo-rotate.sh`, analyze script |
| 11 | [Monitor GCP Cert Rotations with Cloud Monitoring Runbooks](https://computingforgeeks.com/gcp-cert-monitoring-runbook/) | [`article-11`](https://github.com/cfg-labs/gcp-shared-traffic-demo/tree/article-11) | `cert-monitoring` Terraform module + 4 runbooks (rotation, pin update, emergency revocation) + post-mortem template |

## Repository layout

```
.
├── infra/
│   ├── modules/                 # Reusable Terraform modules (6)
│   └── live/article-lab/europe-west1/
│       ├── dns-cfg-lab/         # DNSSEC + CAA delegated zone
│       ├── dns-cfg-regional/    # Second zone for regional demo
│       ├── certs-cfg-lab/       # Global wildcard cert
│       ├── certs-cfg-regional/  # Regional wildcard cert (europe-west1)
│       ├── gxlb-cfg-lab/        # Shared LB + cert map
│       └── private-ca-cfg-lab/  # DevOps-tier CA pool + root CA
├── apps/
│   ├── article-01/              # Pre-consolidation sprawl manifests
│   └── article-05/cfg-demo/     # Gateway API + HTTPRoute + Deployments
├── argocd/
│   ├── bootstrap/               # App-of-apps root
│   └── apps/                    # Per-service ArgoCD Applications
├── clients/
│   └── python-pinned/           # SPKI-pinned Python client
├── policy/
│   └── no-per-service-certs.rego # Conftest guardrail
├── runbooks/                    # 4 runbooks + post-mortem template
└── scripts/                     # session-up, session-down, demo-rotate, audit-certs, traffic-gen, analyze-rotation
```

## Quickstart

Prerequisites: an empty GCP project, OpenTofu (or Terraform), Terragrunt, gcloud, kubectl, and a domain delegated to Cloud DNS.

```
export PROJECT_ID=my-lab-project
export CLOUDFLARE_API_TOKEN=...

make up                    # provisions every stack in dependency order
make argocd                # installs ArgoCD on the cluster, wires app-of-apps
kubectl apply -f apps/article-05/cfg-demo/   # or let ArgoCD reconcile
make demo-rotate           # run the zero-incident rotation demo
make down                  # tears everything down, runs validate-clean
```

Read each article in order for the full narrative; check out the matching tag to see the repo state at that point in the series.

## License

MIT. See `LICENSE`.
