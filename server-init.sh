#!/bin/bash

echo " -------------- packages -------------- "
apt-get update && apt-get upgrade -y
apt-get install -y ufw sed sudo vim curl wget htop jq open-iscsi nfs-common
apt-get autoremove -y && apt update && apt upgrade -y

echo " -------------- user -------------- "
useradd -m -s /bin/bash mp281x
passwd -d mp281x
usermod -aG sudo mp281x
hostnamectl set-hostname dev.mp281x.xyz

echo " ------- ssh key ------- "
mkdir -p /home/mp281x/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/GDK6kPlz3/1O6E0v415HKnoWjYLcdCu/N1ya6DmNEX4e3kiz15SO20bILdtuPzvOXhYpkPogLfincQkGZqCsoIwKBnfPUcODL40M4aWiRpYJnRYDLAO6RNpcm2pnHVExL2Rnw0nGAS+rhmXEHKt3bW5EafhXPOYj7TfzRrU8rOPDHy3qtA2lGzIOeDlYngARvz1nWgo5fd8/8WfDCBTpAJDd9cvvYYokCx7C8M/wgQRx0+nYTLu4EkaFhiwMMRUZ/2I4c6bE8+qbim7W0V5u5NiwXFabU+i5hwoTWLg5mlt+F9xLV2BeGSqN9Su4sfzzkG2AIcEeMC7i0wrG9QGdFxsB3vUi24M7Cp/d2TjLW1eFQwoxB9HGNVydjQW9YrwsKfyLmXnM7aY51UJcHd9u83Zu8nCao2Xg+RURWMHGZsnL1F4F7kfu3JJTU6n3dkxxks5iVl95taIidl7cX1fEtQ9BesVlJD+tmXtxaAWasymaydtdiLU8IVM/b2jAwuk= administrator@mp281x" >> /home/mp281x/.ssh/authorized_keys

echo " ------- firewall ------- "
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 6443
ufw allow 22

echo " ------- ssh ------- "
sudo chmod -x /etc/update-motd.d/*
SSH_CONFIG="
PermitRootLogin no
\nStrictModes yes
\nPubkeyAuthentication yes
\nPasswordAuthentication no
\nChallengeResponseAuthentication no
\nUsePAM yes
\nX11Forwarding no
\nPrintMotd no
\nPrintLastLog no
\nAcceptEnv LANG LC_*
\nSubsystem sftp  /usr/lib/openssh/sftp-server"
echo $SSH_CONFIG > /etc/ssh/sshd_config
echo "" > /etc/motd
service sshd restart

echo " ------- k3s ------- "
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC=" \
    --disable=traefik \
    --node-name k3s-dev" sh -

mv /registry-k3s.yaml /etc/rancher/k3s/registries.yaml    
systemctl daemon-reload
systemctl restart k3s.service

echo " ------- argocd / sealed secrets ------- "
kubectl apply -f /sealedSecrets.key
mv /helm-chart.yaml /var/lib/rancher/k3s/server/manifests/helm-chart.yaml


echo " ------- visualize the connection file ------- "
cp /etc/rancher/k3s/k3s.yaml /home/mp281x/k3s.yaml
sed -i 's/127.0.0.1/dev.mp281x.xyz/g' /home/mp281x/k3s.yaml
clear && cat /home/mp281x/k3s.yaml

echo " ------- clear file -------"
rm /home/mp281x/k3s.yaml 
rm /server-init.sh
rm /helm-chart.yaml
rm /registry-k3s.yaml
rm /sealedSecrets.key


