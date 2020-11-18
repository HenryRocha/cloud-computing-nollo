#!/bin/bash

# Install Wireguard
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard -y

# Enable IPv4 forwarding
sudo sed -i 's/\#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p
sudo echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Create the "server" node config.
cd /etc/wireguard/
cat > ./wg0.conf <<EOF
[Interface]
Address = 10.0.150.20/32
SaveConfig = true
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
PrivateKey = ${WG_BK_SERVER_PVK}

[Peer]
PublicKey = ${WG_BK_ADMIN_PBK}
AllowedIPs = 10.0.150.29/32
EOF

# Enable Wireguard.
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0
