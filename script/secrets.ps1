. ./secrets/secrets.ps1

function EncryptSecret([String] $secret){
    return cmd.exe /c "echo|set /p=${secret}| kubeseal --raw --scope cluster-wide"
}

kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > secrets/sealedSecrets.key

#! Infrastructure
@”
#? Tailscale 
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: tailscale-config
  namespace: tailscale
  annotations: { sealedsecrets.bitnami.com/cluster-wide: "true" }
spec:
  encryptedData:
    TS_AUTH_KEY: $(EncryptSecret($tailscaleToken))

---
#? Cert Manager 
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
  annotations: { sealedsecrets.bitnami.com/cluster-wide: "true" }
spec:
  encryptedData:
    api-token: $(EncryptSecret($cloudflareToken))

---
#? Longhorn
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: s3-secrets
  namespace: longhorn-system
  annotations: { sealedsecrets.bitnami.com/cluster-wide: "true" }
spec:
  encryptedData:
    AWS_ACCESS_KEY_ID: $(EncryptSecret($s3Id))
    AWS_SECRET_ACCESS_KEY: $(EncryptSecret($s3Token))
    AWS_ENDPOINTS: $(EncryptSecret($s3Endpoint))

---
#? Image Updater 
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: github-registry
  namespace: argocd
spec:
  encryptedData:
    .dockerconfigjson: $(EncryptSecret($registryConfig))
  template:
    metadata:
      creationTimestamp: null
      name: github-registry
      namespace: argocd
    type: kubernetes.io/dockerconfigjson
“@ | Out-File -FilePath ./app/infrastructure/secrets.yaml






#! Github actions
@”
#? Github actions 
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: controller-manager
  namespace: github-actions
  annotations: { sealedsecrets.bitnami.com/cluster-wide: "true" }
spec:
  encryptedData:
    github_token: $(EncryptSecret($githubToken))
“@ | Out-File -FilePath ./app/github-actions/secrets.yaml





