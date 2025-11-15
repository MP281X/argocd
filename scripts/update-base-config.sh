#!/bin/bash

# This script updates the k3s base configuration on a running server
# Run this after updating .env to propagate changes

echo "Loading environment variables from .env..."
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please copy bootstrap/config.env.template to .env and fill in your values."
    exit 1
fi

echo "Updating remote server configuration..."
scp .env mp281x@dev.mp281x.xyz:/home/mp281x/config.env
ssh mp281x@dev.mp281x.xyz "sudo mv /home/mp281x/config.env /etc/rancher/k3s/config.env"

scp bootstrap/registry-k3s.yaml mp281x@dev.mp281x.xyz:/home/mp281x/registry-k3s.yaml
ssh mp281x@dev.mp281x.xyz "sudo mv /home/mp281x/registry-k3s.yaml /etc/rancher/k3s/registries.yaml"

scp bootstrap/helm-chart.yaml mp281x@dev.mp281x.xyz:/home/mp281x/helm-chart.yaml
ssh mp281x@dev.mp281x.xyz "sudo mv /home/mp281x/helm-chart.yaml /var/lib/rancher/k3s/server/manifests/helm-chart.yaml"

echo "Restarting k3s to apply changes..."
ssh mp281x@dev.mp281x.xyz "sudo systemctl restart k3s.service"

echo "Configuration updated successfully!"


