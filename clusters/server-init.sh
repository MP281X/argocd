#!/bin/bash

echo " -------------- packages setup -------------- "
apt-get update && apt-get upgrade -y
apt-get install -y ufw sed sudo vim curl wget htop
apt-get autoremove -y && apt update && apt upgrade -y

echo " -------------- user setup -------------- "
useradd -m -s /bin/bash mp281x
echo mp281x:3002 | chpasswd
usermod -aG sudo mp281x
hostnamectl set-hostname dev.mp281x.xyz

echo " ------- ssh key setup ------- "
mkdir -p /home/mp281x/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/GDK6kPlz3/1O6E0v415HKnoWjYLcdCu/N1ya6DmNEX4e3kiz15SO20bILdtuPzvOXhYpkPogLfincQkGZqCsoIwKBnfPUcODL40M4aWiRpYJnRYDLAO6RNpcm2pnHVExL2Rnw0nGAS+rhmXEHKt3bW5EafhXPOYj7TfzRrU8rOPDHy3qtA2lGzIOeDlYngARvz1nWgo5fd8/8WfDCBTpAJDd9cvvYYokCx7C8M/wgQRx0+nYTLu4EkaFhiwMMRUZ/2I4c6bE8+qbim7W0V5u5NiwXFabU+i5hwoTWLg5mlt+F9xLV2BeGSqN9Su4sfzzkG2AIcEeMC7i0wrG9QGdFxsB3vUi24M7Cp/d2TjLW1eFQwoxB9HGNVydjQW9YrwsKfyLmXnM7aY51UJcHd9u83Zu8nCao2Xg+RURWMHGZsnL1F4F7kfu3JJTU6n3dkxxks5iVl95taIidl7cX1fEtQ9BesVlJD+tmXtxaAWasymaydtdiLU8IVM/b2jAwuk= administrator@mp281x" >> /home/mp281x/.ssh/authorized_keys

echo " ------- firewall setup ------- "
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 6443
ufw allow 22

echo " ------- ssh configuration ------- "
chmod -x /etc/update-motd.d/*
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
echo -e $SSH_CONFIG > /etc/ssh/sshd_config
echo "" > /etc/motd
service sshd restart

echo " ------- k3s configuration ------- "
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --no-deploy traefik --node-name k3s-dev
vi /etc/rancher/k3s/registries.yaml
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/mp281x/.bashrc
clear && cat /etc/rancher/k3s/k3s.yaml
ufw enable

