#! /bin/bash

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
cd cloud-computing-nollo/nollo-site/

sudo docker build -t nollo-site --build-arg API_URL="http://${NOLLO_API_LB_DNS}" .
sudo docker run -d -p 80:5000 --name=run-nollo-site nollo-site
