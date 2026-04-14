# Python SPKI-Pinned Client

Companion code for Article 8 of the series. Validates the TLS chain against the Private CA root (`root-ca.pem`) AND checks the observed Subject Public Key Info SHA-256 against an approved pin set. Connecting to a host whose cert key is not in `PINS` raises `ssl.SSLError` before any application data flows.

## Install

```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Extract root CA PEM

```
gcloud privateca roots describe cfg-lab-root-ca \
  --location=europe-west1 \
  --pool=cfg-lab-devops-pool \
  --format="value(pemCaCertificates)" > root-ca.pem
```

## Compute the SPKI pin to paste into `PINS`

```
openssl x509 -in pay.pem -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

## Run

```
ROOT_CA_PEM=./root-ca.pem python3 pinned_client.py
```

## Rotation scenarios

- Same-key rotation: pin holds, no client update needed.
- New-key rotation: pre-pin the next key's SPKI in `PINS` (as a backup pin) BEFORE rotating the cert. After the fleet has soaked on the updated client, rotate; remove the old pin in a subsequent client release.
- Emergency pin change: ship a client update with ONLY the new pin; accept that pre-update clients lock themselves out until they update.
