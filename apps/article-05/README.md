# Article 05 — GKE Ingress to Gateway API Migration

Manifests deployed to the `cfg-demo` namespace on GKE Autopilot, replacing the per-service `Ingress + ManagedCertificate` sprawl from `apps/article-01/` with a shared `Gateway + HTTPRoute` pattern that attaches the wildcard cert from Article 3 via the `networking.gke.io/certmap` annotation.

## Apply order

```
kubectl apply -f namespace.yaml
kubectl apply -f deployments.yaml
kubectl apply -f services.yaml
kubectl apply -f gateway.yaml
kubectl apply -f httproutes.yaml
```

The Gateway takes 3-4 minutes to reach `PROGRAMMED=True` and populate its `ADDRESS`. Once it does, add Cloud DNS A records for `food-gw` and `admin-gw` pointing at that IP in the `cfg-lab` zone.

## Prerequisites

- GKE Autopilot cluster with Gateway API enabled
- Certificate Map `cfg-lab-cert-map` exists in the same project (global scope), populated by `infra/live/article-lab/europe-west1/gxlb-cfg-lab/` from Article 4
- Delete the per-service `Ingress + ManagedCertificate` objects from `apps/article-01/` first to free the global IP quota before applying the Gateway
