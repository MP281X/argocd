#!/bin/bash

echo " -------------- packages setup -------------- "
apt-get update && apt-get upgrade -y
apt-get install -y firewalld sed sudo vim curl wget htop jq open-iscsi nfs-common
apt-get autoremove -y && apt update && apt upgrade -y
curl -fsSL https://tailscale.com/install.sh | sh && tailscale up

echo " -------------- user setup -------------- "
useradd -m -s /bin/bash mp281x
echo mp281x:3002 | chpasswd
usermod -aG sudo mp281x
hostnamectl set-hostname dev.mp281x.xyz

echo " ------- ssh key setup ------- "
mkdir -p /home/mp281x/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/GDK6kPlz3/1O6E0v415HKnoWjYLcdCu/N1ya6DmNEX4e3kiz15SO20bILdtuPzvOXhYpkPogLfincQkGZqCsoIwKBnfPUcODL40M4aWiRpYJnRYDLAO6RNpcm2pnHVExL2Rnw0nGAS+rhmXEHKt3bW5EafhXPOYj7TfzRrU8rOPDHy3qtA2lGzIOeDlYngARvz1nWgo5fd8/8WfDCBTpAJDd9cvvYYokCx7C8M/wgQRx0+nYTLu4EkaFhiwMMRUZ/2I4c6bE8+qbim7W0V5u5NiwXFabU+i5hwoTWLg5mlt+F9xLV2BeGSqN9Su4sfzzkG2AIcEeMC7i0wrG9QGdFxsB3vUi24M7Cp/d2TjLW1eFQwoxB9HGNVydjQW9YrwsKfyLmXnM7aY51UJcHd9u83Zu8nCao2Xg+RURWMHGZsnL1F4F7kfu3JJTU6n3dkxxks5iVl95taIidl7cX1fEtQ9BesVlJD+tmXtxaAWasymaydtdiLU8IVM/b2jAwuk= administrator@mp281x" >> /home/mp281x/.ssh/authorized_keys

echo " ------- firewall setup ------- "
# enable firewalld
systemctl start firewalld
systemctl enable firewalld

# remove the active service from the default interface
firewall-cmd --remove-service=ssh --permanent
firewall-cmd --remove-service=dhcpv6-client --permanent
firewall-cmd --set-target=DROP --permanent

# create a new zone for tailscale
firewall-cmd --new-zone=tailscale --permanent
firewall-cmd --zone=tailscale --add-source=100.64.0.0/10 --permanent
firewall-cmd --zone=tailscale --change-interface=tailscale0 --permanent

# add the service to the tailscale zone
firewall-cmd --zone=tailscale --add-port=22/tcp --permanent
firewall-cmd --zone=tailscale --add-port=80/tcp --permanent
firewall-cmd --zone=tailscale --add-port=443/tcp --permanent

# add kubernetes port to the tailscale zone
firewall-cmd --zone=tailscale --add-port=6443/tcp --permanent
firewall-cmd --zone=tailscale --add-port=8472/udp --permanent
firewall-cmd --zone=tailscale --add-port=10250/udp --permanent
firewall-cmd --zone=tailscale --add-port=2379/udp --permanent
firewall-cmd --zone=tailscale --add-port=2380/udp --permanent

# reload the firewall config
firewall-cmd --reload

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
TAILSCALEIP=$(sudo tailscale ip --4)
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.7+k3s1 sh -s - --write-kubeconfig-mode 644 \ 
    --no-deploy traefik \ 
    --node-name k3s-dev \ 
    --bind-address $TAILSCALEIP \ 
    --node-ip $TAILSCALEIP \ 
    --node-external-ip $TAILSCALEIP 
    
systemctl daemon-reload
systemctl restart k3s.service
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /home/mp281x/.bashrc
cp /etc/rancher/k3s/k3s.yaml /home/mp281x/k3s.yaml
sed -i 's/127.0.0.1/dev.mp281x.xyz/g' /home/mp281x/k3s.yaml

echo " ------- argocd configuration ------- "
kubectl create namespace argocd
kubectl create ns sealed-secrets
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
