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
    api-token: $(echo -n $CLOUDFLARE_TOKEN | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

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
    AWS_ACCESS_KEY_ID: $(echo -n $S3_ID | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    AWS_SECRET_ACCESS_KEY: $(echo -n $S3_TOKEN | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)
    AWS_ENDPOINTS: $(echo -n $S3_ENDPOINT | tr -d '\r' | kubeseal --controller-name=sealed-secrets --raw --scope cluster-wide)

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
