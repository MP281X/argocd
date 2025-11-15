#!/bin/bash
set -e

# load .env
export $(grep -v '^#' .env | grep -v '^$' | xargs)

# Update registry configuration
envsubst < bootstrap/registry-k3s.yaml | ssh mp281x@dev.mp281x.xyz "cat > /home/mp281x/registry-k3s.yaml"
ssh mp281x@dev.mp281x.xyz "sudo mv /home/mp281x/registry-k3s.yaml /etc/rancher/k3s/registries.yaml"

# Update helm chart manifests
envsubst < bootstrap/helm-chart.yaml | ssh mp281x@dev.mp281x.xyz "cat > /home/mp281x/helm-chart.yaml"
ssh mp281x@dev.mp281x.xyz "sudo mv /home/mp281x/helm-chart.yaml /var/lib/rancher/k3s/server/manifests/helm-chart.yaml"

# Clean unused container images
ssh mp281x@dev.mp281x.xyz "sudo k3s crictl rmi --prune"

# Restart k3s service
ssh mp281x@dev.mp281x.xyz "sudo systemctl restart k3s.service"

# Update apt packages
ssh mp281x@dev.mp281x.xyz "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y"
