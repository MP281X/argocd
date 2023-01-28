# get the argocd password and login in the cli
$base64Password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}';
$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Password));
argocd login localhost:8080 --username admin --password $password;
argocd account update-password --current-password $password --new-password "password"

# apply the cluster init yaml and display the argocd password
kubectl apply -f k3s-dev.yaml;