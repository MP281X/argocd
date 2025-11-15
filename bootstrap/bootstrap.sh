#!/bin/bash

echo " -------------- packages -------------- "
apt-get update && apt-get upgrade -y
apt-get install -y ufw sudo curl wget htop
apt-get autoremove -y

echo " -------------- user -------------- "
useradd -m -s /bin/bash mp281x
passwd -d mp281x
usermod -aG sudo mp281x
hostnamectl set-hostname dev.mp281x.xyz

echo " ------- ssh key ------- "
mkdir -p /home/mp281x/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxArbBf6JivomRmW6pB5OtmGPp1jHJAiAIDMZ/Kh0Hb paludgnachmatteo.dev@gmail.com" >> /home/mp281x/.ssh/authorized_keys
chmod 700 /home/mp281x/.ssh && chmod 600 /home/mp281x/.ssh/authorized_keys
chown -R mp281x:mp281x /home/mp281x/.ssh

echo " ------- firewall ------- "
sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 6443
ufw limit 22/tcp
ufw enable

echo " ------- ssh ------- "
cat > /etc/ssh/sshd_config << EOF
# Authentication
AllowUsers mp281x
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no

# Rate limiting & DoS protection
MaxSessions 3
MaxAuthTries 3
LoginGraceTime 30

# Security options
PrintMotd no
Compression no
PrintLastLog no
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 120
EOF

sudo chmod -x /etc/update-motd.d/*
echo "" > /etc/motd

systemctl restart sshd

echo " ------- k3s ------- "
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC=" \
    --disable=traefik \
    --node-name k3s-dev" sh -

systemctl daemon-reload
systemctl restart k3s.service

echo " ------- visualize the connection file ------- "
cp /etc/rancher/k3s/k3s.yaml /home/mp281x/k3s.yaml
sed -i 's/127.0.0.1/dev.mp281x.xyz/g' /home/mp281x/k3s.yaml

echo " ------- clear file -------"
rm /bootstrap.sh
