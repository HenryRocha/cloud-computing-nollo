#! /bin/bash

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Download the MySQL database Docker Compose file
wget https://raw.githubusercontent.com/HenryRocha/cloud-computing-nollo/main/migrator/docker-compose.yaml

sudo docker-compose up -d
