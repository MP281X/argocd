cat ./secrets.x.yaml | kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --format=yaml > ./secrets.yaml
#test2