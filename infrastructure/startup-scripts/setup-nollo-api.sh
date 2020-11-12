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
cd cloud-computing-nollo/nollo-api/

sudo docker build -t nollo-api .
sudo docker run -it --rm -d -p 80:8001 -e DB_DSN="${NOLLO_API_DSN}" --name run-nollo-api nollo-api
