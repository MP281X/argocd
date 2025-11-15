# delete the ssh known_hosts file
rm ~/.ssh/known_hosts
rm ~/.ssh/known_hosts.old
rm ~/.kube/config

# copy files directly to their final locations
scp bootstrap/server-init.sh root@dev.mp281x.xyz:/server-init.sh

# k3s config files
ssh root@dev.mp281x.xyz "mkdir -p /etc/rancher/k3s"
scp .env root@dev.mp281x.xyz:/etc/rancher/k3s/config.env
scp bootstrap/registry-k3s.yaml root@dev.mp281x.xyz:/etc/rancher/k3s/registries.yaml

# k3s manifests
ssh root@dev.mp281x.xyz "mkdir -p /var/lib/rancher/k3s/server/manifests"
scp bootstrap/helm-chart.yaml root@dev.mp281x.xyz:/var/lib/rancher/k3s/server/manifests/helm-chart.yaml

# run the init script
ssh root@dev.mp281x.xyz "sh /server-init.sh"

# copy the k8s config file
scp mp281x@dev.mp281x.xyz:/home/mp281x/k3s.yaml ~/.kube/config

