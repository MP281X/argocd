#!/bin/bash

echo " -------------- packages setup -------------- "
sudo apt-get update && apt-get upgrade -y
sudo apt-get install -y vim jq open-iscsi nfs-common
sudo apt-get autoremove -y && apt update && apt upgrade -y
curl -fsSL https://tailscale.com/install.sh | sudo sh && sudo tailscale up

echo " ------- ssh configuration ------- "
sudo iptables -F
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
echo -e $SSH_CONFIG > /etc/ssh/sshd_config
echo "" > /etc/motd
sudo service sshd restart

echo " ------- k3s configuration ------- "
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.7+k3s1 sh -s - --write-kubeconfig-mode 644 --no-deploy traefik --node-name k3s-dev

sudo vi /etc/rancher/k3s/registries.yaml    
sudo systemctl daemon-reload
sudo systemctl restart k3s.service

echo " ------- argocd installation ------- "
kubectl create namespace argocd
kubectl create ns sealed-secrets
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo " ------- visualize the connection file ------- "
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/k3s.yaml
sudo sed -i 's/127.0.0.1/dev.mp281x.xyz/g' /home/ubuntu/k3s.yaml
clear && cat /home/ubuntu/k3s.yaml
sudo rm /home/ubuntu/k3s.yaml && sudo rm /home/ubuntu/init.sh