cd C:\dev\argocd;
kubectl get secret -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > clusters/key/k3s-dev.key
cd C:\dev\argocd\app;
Get-ChildItem -recurse | 
where {$_.name -eq "secrets.x.yaml"} | 
foreach { cd $_.DirectoryName; cat ./secrets.x.yaml | kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --format=yaml > ./secrets.yaml };
cd C:\dev\argocd\