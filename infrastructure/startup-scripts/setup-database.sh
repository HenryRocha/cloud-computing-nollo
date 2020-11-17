#!/bin/bash

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo apt install git -y

# Change to home directory
cd /home/ubuntu

# Clone the repo
git clone https://github.com/HenryRocha/cloud-computing-nollo.git
cd cloud-computing-nollo/database/

# Replace the hardcoded passwords.
sudo sed -i 's/\NOLLO_DB_ROOT_PW_PLACEHOLDER/${NOLLO_DB_ROOT_PW}/g' ./docker-compose.yaml
sudo sed -i 's/\NOLLO_DB_ADMIN_PW_PLACEHOLDER/${NOLLO_DB_ADMIN_PW}/g' ./scripts/db-on-create.sql
sudo sed -i 's/\NOLLO_DB_API_PW_PLACEHOLDER/${NOLLO_DB_API_PW}/g' ./scripts/db-on-create.sql

# Create the Docker container and run it.
sudo docker-compose up -d
