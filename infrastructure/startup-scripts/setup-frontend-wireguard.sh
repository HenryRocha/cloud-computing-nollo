#!/bin/bash

# Install Wireguard
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard openresolv -y

# Enable IPv4 forwarding
sudo sed -i 's/\#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p
sudo echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Create the "server" node config.
cd /etc/wireguard/
cat > ./wg0.conf <<EOF
[Interface]
Address = 10.10.150.75/32
SaveConfig = true
ListenPort = 51820
PrivateKey = ${WG_FE_SERVER_PVK}

[Peer]
PublicKey = ${WG_BE_SERVER_PBK}
AllowedIPs = 10.10.150.20/32, 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24, 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
Endpoint = ${WG_BE_SERVER_IP}:51820
PersistentKeepalive = 15
EOF

# Enable Wireguard.
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0
