# remove the ssh previus host configuration
rm C:\Users\mp281x\.ssh\known_hosts;
rm C:\Users\mp281x\.ssh\known_hosts.old;

# copy the init script and the registry configuration
scp ./clusters/server-init.sh root@dev.mp281x.xyz:/root/init.sh;
scp ./clusters/key/registry-k3s.yaml root@dev.mp281x.xyz:/root/registry-k3s.yaml;
ssh root@dev.mp281x.xyz 'apt install dos2unix && dos2unix init.sh && dos2unix registry-k3s.yaml'

# run the setup script
ssh root@dev.mp281x.xyz 'bash /root/init.sh';

# get the kubeconfig file
scp mp281x@dev.mp281x.xyz:/home/mp281x/k3s.yaml C:\Users\mp281x\.kube\config;
