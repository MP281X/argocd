# delete the ssh known_hosts file
rm C:\Users\mp281x\.ssh\known_hosts;
rm C:\Users\mp281x\.ssh\known_hosts.old;

# copy the config file
scp server-init.sh root@dev.mp281x.xyz:/
scp secrets/helm-chart.yaml root@dev.mp281x.xyz:/
scp secrets/registry-k3s.yaml root@dev.mp281x.xyz:/
scp secrets/sealedSecrets.key root@dev.mp281x.xyz:/

# run the init script
ssh mp281x@dev.mp281x.xyz "sh server-init.sh"

