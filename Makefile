SHELL := /usr/bin/env bash

.PHONY: up down audit argocd demo-rotate

up:
	./scripts/session-up.sh

down:
	./scripts/session-down.sh

audit:
	./scripts/audit-certs.sh

argocd:
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl apply -f argocd/bootstrap/app-of-apps.yaml

demo-rotate:
	./scripts/demo-rotate.sh
