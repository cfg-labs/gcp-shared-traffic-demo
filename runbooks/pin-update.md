# Runbook: Update SPKI Pin (Client Fleet)

Applies to: clients pinning against `pay.cfg-lab.computingforgeeks.com` (Python, mobile apps, etc.).

## When This Runs

Before every new-key rotation of the financial cert. Never after.

## Steps

1. Generate the next keypair and CSR:

   ```
   openssl genrsa -out pay-next.key 2048
   openssl req -new -key pay-next.key -out pay-next.csr \
     -subj "/CN=pay.cfg-lab.computingforgeeks.com/O=ComputingForGeeks Lab"
   ```

2. Compute the SPKI pin on the next key:

   ```
   openssl req -in pay-next.csr -pubkey -noout \
     | openssl pkey -pubin -outform DER \
     | openssl dgst -sha256 -binary \
     | openssl enc -base64
   ```

3. Ship a client update adding the next pin to the approved set ALONGSIDE the current pin:

   ```python
   PINS = {
       "<current-pin>",
       "<next-pin>",  # pre-pinned for upcoming rotation
   }
   ```

4. Monitor client telemetry for fleet adoption. Threshold: 95% of active installs on the updated build.
5. Execute the new-key rotation (see `cert-rotation-private-ca.md`).
6. After 1 week of clean operation, ship another client update removing the old pin.
7. Generate the next-next keypair and repeat from step 1.

## Emergency Pin Change (No Rotation Soak)

If the current pin is compromised and must be removed immediately, accept that pre-update clients will lock themselves out. There is no safe emergency path; this is the cost of pinning.
