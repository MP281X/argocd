function EncryptSecret([String] $secret){
    return cmd.exe /c "echo|set /p=${secret}| kubeseal --raw --scope cluster-wide"
}

$a = EncryptSecret("ciao-test-secret")

echo $a

#* Test
@”
#? Tailscale 
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: test
  namespace: default
  annotations: { sealedsecrets.bitnami.com/cluster-wide: "true" }
spec:
  encryptedData:
    scret1: ${a}
“@ | Out-File -FilePath ./app/app/test.yaml
