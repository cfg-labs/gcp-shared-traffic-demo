# Runbook: Emergency Cert Revocation

Applies to: suspected cert compromise where the cert is actively issuing malicious traffic and must stop immediately.

## Severity

P0. Page on-call. Do not debug - revoke first, investigate second.

## Steps

1. Identify the cert: which project, which resource name, which LB(s) reference it.

2. For Private CA certs (revocable via API):

   ```
   gcloud privateca certificates revoke <cert-id> \
     --issuer-pool=cfg-lab-devops-pool \
     --issuer-location=europe-west1 \
     --reason=UNSPECIFIED
   ```

3. For Certificate Manager (Google-managed) certs, there is no direct revoke API. Remove the cert from every cert map entry referencing it:

   ```
   cd infra/live/article-lab/europe-west1/gxlb-cfg-lab
   # Edit terragrunt.hcl to remove the compromised cert's entries
   terragrunt apply -auto-approve
   ```

4. If the compromise extends to the CA (not just one cert): update CAA records to block the CA entirely:

   ```
   cd infra/live/article-lab/europe-west1/dns-cfg-lab
   # Remove compromised CA from caa_issuers input in terragrunt.hcl
   terragrunt apply -auto-approve
   ```

5. Cut traffic over to a backup cert/LB if one exists. If not, accept the outage until a replacement cert is issued.

6. Open an incident ticket referencing the post-mortem template. Precautionary: consider rotating every cert issued from the same CA in the preceding 30 days.

## Post-Incident

- Full post-mortem within 48 hours using `runbooks/post-mortem-template.md`.
- Review access paths that allowed the compromise (IAM roles on the CA pool, credential leaks, etc.).
- Update CI policies if a control gap is identified.
