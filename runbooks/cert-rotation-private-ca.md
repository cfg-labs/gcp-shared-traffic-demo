# Runbook: Rotate Private CA Cert (Financial Service)

Applies to: `pay.cfg-lab.computingforgeeks.com` cert issued by `cfg-lab-root-ca`.

## Schedule

- Same-key rotation every 60-90 days
- New-key rotation every 12-18 months (requires coordinated client update, see pin-update runbook)

## Same-Key Rotation Steps

1. Reuse the existing CSR (same private key).
2. Issue new cert from the CA pool:

   ```
   gcloud privateca certificates create pay-cert-$(date +%Y%m%d) \
     --issuer-pool=cfg-lab-devops-pool \
     --issuer-location=europe-west1 \
     --csr=apps/food-pay/pay.csr \
     --cert-output-file=/tmp/pay-rotated.pem \
     --validity=P90D
   ```

3. Verify chain against root CA:

   ```
   openssl verify -CAfile root-ca.pem /tmp/pay-rotated.pem
   ```

4. Deploy via Terraform to the dedicated financial LB (blue-green pattern):

   ```
   terragrunt apply -var="pay_cert_pem_file=/tmp/pay-rotated.pem"
   ```

5. Soak for 1 hour with traffic generator running (`./scripts/traffic-gen`).
6. Destroy old cert resource in Terraform.

## New-Key Rotation Steps

See `pin-update.md` first - new-key rotation must be preceded by a pin-update cycle. Then follow the same-key rotation steps with a fresh CSR (new keypair).

## Rollback

Private CA cert rotation is reversible during the blue-green window: repoint the forwarding rule at the old target proxy holding the prior cert. Once the old cert is destroyed, the only rollback is to reissue a new cert and redeploy.
