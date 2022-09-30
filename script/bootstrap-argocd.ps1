kubectl apply -f clusters/key/github-registry.yaml;

# install the sealed secrets token
kubectl create ns sealed-secrets;
kubectl apply -f clusters/key/k3s-dev.key;

# get the argocd password and login in the cli
$base64Password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}';
$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Password));
argocd login localhost:8080 --username admin --password $password;

# add the github repo credentials
$token = $args[0];
argocd repo add https://github.com/MP281X/argocd --username mp281x --password $token;
argocd repo add https://github.com/MP281X/dicantieri --username mp281x --password $token;

# applay the cluster init yaml and display the argocd password
kubectl apply -f clusters/k3s-dev.yaml;
echo $password