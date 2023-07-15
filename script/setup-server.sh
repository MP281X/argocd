# delete the ssh known_hosts file
rm ~/.ssh/known_hosts
rm ~/.ssh/known_hosts.old
rm ~/.kube/config

# copy the config file
scp server-init.sh root@dev.mp281x.xyz:/
scp secrets/helm-chart.yaml root@dev.mp281x.xyz:/
scp secrets/registry-k3s.yaml root@dev.mp281x.xyz:/
scp secrets/sealedSecrets.key root@dev.mp281x.xyz:/

# run the init script
ssh root@dev.mp281x.xyz "sh /server-init.sh"

# copy the k8s config file
scp mp281x@dev.mp281x.xyz:/home/mp281x/k3s.yaml ~/.kube/config
