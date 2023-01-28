$test = "ciao-1"
$scret1 =  cmd.exe /c "echo|set /p='${test}' | kubeseal --raw --scope cluster-wide"

#* Test
@”
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: test
  namespace: default
  annotations:
    sealedsecrets.bitnami.com/cluster-wide: "true"
spec:
  encryptedData:
    scret1: ${scret1}
  template:
    metadata:
      creationTimestamp: null
      name: test
      namespace: default
“@ | Out-File -FilePath ./app/app/test.yaml



