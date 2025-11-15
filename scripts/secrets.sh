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
