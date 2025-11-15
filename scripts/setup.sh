#!/bin/bash
set -e

# delete the ssh known_hosts file
rm -f ~/.kube/config
rm -f ~/.ssh/known_hosts
rm -f ~/.ssh/known_hosts.old

# load .env
export $(grep -v '^#' .env | grep -v '^$' | xargs)

# copy init script
scp bootstrap/bootstrap.sh root@dev.mp281x.xyz:/bootstrap.sh

# # k3s config files
# ssh root@dev.mp281x.xyz "mkdir -p /etc/rancher/k3s"
#
# # Process and copy registry config with envsubst
# envsubst < bootstrap/registry-k3s.yaml | ssh root@dev.mp281x.xyz "cat > /etc/rancher/k3s/registries.yaml"
#
# # k3s manifests
# ssh root@dev.mp281x.xyz "mkdir -p /var/lib/rancher/k3s/server/manifests"
#
# # Process and copy helm-chart with envsubst
# envsubst < bootstrap/helm-chart.yaml | ssh root@dev.mp281x.xyz "cat > /var/lib/rancher/k3s/server/manifests/helm-chart.yaml"

# run the init script
ssh root@dev.mp281x.xyz "sh /bootstrap.sh"

# copy the k8s config file
ssh mp281x@dev.mp281x.xyz "cat /home/mp281x/k3s.yaml" > ~/.kube/config
