# Article 01 — Per-Service Certificate Sprawl

This directory contains the "sprawl" pattern: each service gets its own Deployment, Service, Ingress, ManagedCertificate, and static IP. This is the pattern that grows organically when platform teams onboard services one-by-one without a shared LB strategy.

Count: 3 services × 5 resources × 1 static IP = 18 GCP + K8s objects for three "hello world" services. In production at scale, multiply by 30+ services.

## Deploy

Prerequisites: GKE Autopilot cluster named `cfg-lab-gke` in `labs-491519/europe-west1`, DNS zone `cfg-lab.computingforgeeks.com` with A records pointing at the reserved IPs.

```
kubectl apply -f food-sprawl.yaml
kubectl apply -f admin-sprawl.yaml
kubectl apply -f api-sprawl.yaml
```

Wait 15-30 minutes for ManagedCertificate provisioning. Check:

```
kubectl get managedcertificate -A
```

## Cleanup (do this at the end of Article 5 — we migrate to shared LB there)

```
kubectl delete -f . --ignore-not-found
for svc in food-sprawl admin-sprawl api-sprawl; do
  gcloud compute addresses delete ${svc}-ip --global --project=labs-491519 --quiet
  gcloud dns record-sets delete ${svc}.cfg-lab.computingforgeeks.com. --type=A --zone=cfg-lab --project=labs-491519
done
```
