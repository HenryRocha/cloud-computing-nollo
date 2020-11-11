#! /bin/bash

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo apt install git -y

# Clone the repo
git clone https://github.com/HenryRocha/cloud-computing-nollo.git
cd cloud-computing-nollo/migrator/

sudo docker-compose up -d
