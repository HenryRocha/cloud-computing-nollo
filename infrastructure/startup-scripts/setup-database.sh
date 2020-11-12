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
cd cloud-computing-nollo/migrator/

# Create the scripts folder.
mkdir scripts

# Create the init database.
cat > ./scripts/setup_db.sql <<EOF
DROP DATABASE IF EXISTS nollo_prod;
CREATE DATABASE nollo_prod;

DROP DATABASE IF EXISTS nollo_dev;
CREATE DATABASE nollo_dev;

DROP USER IF EXISTS nollo_admin@"%";
CREATE USER nollo_admin@"%" IDENTIFIED BY "${NOLLO_DB_ADMIN_PW}";
GRANT ALL ON nollo_prod.* TO nollo_admin@"%";
GRANT ALL ON nollo_dev.* TO nollo_admin@"%";

DROP USER IF EXISTS nollo_api@"%";
CREATE USER nollo_api@"%" IDENTIFIED BY "${NOLLO_DB_API_PW}";
GRANT SELECT, INSERT, UPDATE, DELETE ON nollo_prod.* TO nollo_api@"%";
GRANT SELECT, INSERT, UPDATE, DELETE ON nollo_dev.* TO nollo_api@"%";

COMMIT

DROP TABLE IF EXISTS nollo_dev.todos;

CREATE TABLE nollo_dev.todos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(50) NOT NULL,
    description VARCHAR(120),
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO nollo_dev.todos VALUES (1, "Harcoded Todo 1", "This todo was created with the database.", "1999-01-01 06:30:00");
INSERT INTO nollo_dev.todos VALUES (2, "Harcoded Todo 2", "This todo was created with the database.", "2000-04-14 06:30:00");
EOF

# Create the Docker container and run it.
sudo docker-compose up -d
