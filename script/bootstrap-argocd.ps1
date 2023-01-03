# configure all the secrets
kubectl apply -f secrets/secrets-dev.yaml
kubectl apply -f secrets/secrets-app.yaml

# get the argocd password and login in the cli
$base64Password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}';
$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Password));
argocd login localhost:8080 --username admin --password $password;
argocd account update-password --current-password $password --new-password "password"

# add the github repo credentials
$token = $args[0];
argocd repo add https://github.com/MP281X/argocd --username mp281x --password $token;
argocd repo add https://github.com/MP281X/dicantieri --username mp281x --password $token;

# apply the cluster init yaml and display the argocd password
kubectl apply -f k3s-dev.yaml;