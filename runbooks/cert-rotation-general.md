# Runbook: Rotate General Wildcard Cert

Applies to: Google-managed certs on the shared LB (`cfg-lab-wildcard` and similar).

## Triggers

- Alert `Certificate Manager cert expiring in 30d` or `7d` fires
- Alert `Certificate Manager ACME challenge failures` fires

## Steps

1. Check cert state: `gcloud certificate-manager certificates describe <name>`. If `FAILED`, skip to step 4.
2. Check DNS authorization: `gcloud certificate-manager dns-authorizations describe <auth-name>`.
3. Verify CNAME propagation: `dig +short CNAME _acme-challenge.<domain> @1.1.1.1`.
4. If broken, fix the root cause (usually DS record at the parent or CAA policy). Then force a renewal attempt:

   ```
   cd infra/live/article-lab/europe-west1/certs-cfg-lab
   terragrunt taint google_certificate_manager_certificate.this[\"cfg-lab-wildcard\"]
   terragrunt apply
   ```

5. Watch the state move `PROVISIONING` -> `ACTIVE` (under 10 minutes for DNS-01).
6. Close the alert.

## Rollback

Google-managed certs do not allow arbitrary downgrade. If the new cert was issued from a different chain and breaks clients, remove the cert map entry pointing at the new cert and repoint at the prior one (if still within validity). If the prior cert expired, you must fix the issuance path; no rollback is available.
