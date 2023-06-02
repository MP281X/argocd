#!/bin/bash

# load env
source secrets/.env;

kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > secrets/sealedSecrets.key;

#! Infrastructure
printf "%s
#? Cert Manager
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
  annotations: { sealedsecrets.bitnami.com/cluster-wide: 'true' }
spec:
  encryptedData:
    api-token: $(printf $CLOUDFLARE_TOKEN| kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

---
#? Longhorn
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: s3-secrets
  namespace: longhorn-system
  annotations: { sealedsecrets.bitnami.com/cluster-wide: 'true' }
spec:
  encryptedData:
    AWS_ACCESS_KEY_ID: $(printf $S3_ID| kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    AWS_SECRET_ACCESS_KEY: $(printf $S3_TOKEN| kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    AWS_ENDPOINTS: $(printf $S3_ENDPOINT| kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

---
#? Tailscale
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: tailscale
  namespace: tailscale
  annotations: { sealedsecrets.bitnami.com/cluster-wide: 'true' }
spec:
  encryptedData:
    AUTH_KEY: $(printf $TAILSCALE_TOKEN| kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

" > app/infrastructure/secrets.yaml

#! Kaniko
printf "%s
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: github-token
  namespace: kaniko
  annotations: { sealedsecrets.bitnami.com/cluster-wide: 'true' }
spec:
  encryptedData:
    github_token: $(printf $GITHUB_TOKEN| kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

" > app/ci-cd/secrets.yaml
