scp secrets/helm-chart.yaml mp281x@dev.mp281x.xyz:/home/mp281x/helm-chart.yaml
ssh mp281x@dev.mp281x.xyz "sudo mv /home/mp281x/helm-chart.yaml /var/lib/rancher/k3s/server/manifests/helm-chart.yaml"
