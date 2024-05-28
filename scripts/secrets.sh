#!/bin/bash

# load env
. secrets/.env;

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
    api-token: $(echo -n $CLOUDFLARE_TOKEN | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

---
#? Restic
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: restic-secrets
  namespace: restic
  annotations: { sealedsecrets.bitnami.com/cluster-wide: 'true' }
spec:
  encryptedData:
    RESTIC_REPOSITORY: $(echo -n $RESTIC_REPOSITORY | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    RESTIC_PASSWORD: $(echo -n $RESTIC_PASSWORD | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    AWS_ACCESS_KEY_ID: $(echo -n $AWS_ACCESS_KEY_ID | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    AWS_SECRET_ACCESS_KEY: $(echo -n $AWS_SECRET_ACCESS_KEY | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

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
    AUTH_KEY: $(echo -n $TAILSCALE_TOKEN | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

" > app/infrastructure/secrets.yaml
