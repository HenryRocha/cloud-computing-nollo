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

# Replace the placeholder on Caddyfile.
sudo sed -i 's/\NOLLO_API_LB_DNS/${NOLLO_API_LB_DNS}/g' /home/ubuntu/cloud-computing-nollo/reverse-proxy/Caddyfile

# Build the Svelte app container.
sudo docker build -t nollo-site \
--build-arg API_URL="http://${NOLLO_SITE_LB_DNS}" \
/home/ubuntu/cloud-computing-nollo/nollo-site/

# Run the Svelte app container.
sudo docker run -d -p 8080:5000 --name=run-nollo-site nollo-site

# Create and run the reverse proxy container.
sudo docker run -d -p 80:80 \
-v /home/ubuntu/cloud-computing-nollo/reverse-proxy/Caddyfile:/etc/caddy/Caddyfile \
-v /home/ubuntu/cloud-computing-nollo/reverse-proxy/caddy_data:/data \
--name=nollo-caddy \
--network=host \
caddy
