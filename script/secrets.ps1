$test = "ciao-1"
$scret1 =  cmd.exe /c "echo|set /p=${test}| kubeseal --raw --scope cluster-wide"

#* Test
@”
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: test
  namespace: default
  annotations: { sealedsecrets.bitnami.com/cluster-wide: "true" }
spec:
  encryptedData:
    scret1: ${scret1}
“@ | Out-File -FilePath ./app/app/test.yaml



