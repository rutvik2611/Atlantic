#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_DIR="/app/development"
LOCAL_DIR="./development"
ENV_FILE="remote.env"  # Change this if you want to use a different env file
EXCLUDE_DIR="persist"  # Directory to exclude during rsync

# Install Docker, Docker Compose, and zip on the remote server
ssh $SSH_USER@$SSH_HOST << 'EOF'
# Update the package index
apt-get update

# Install dependencies
apt-get install -y apt-transport-https ca-certificates curl software-properties-common zip

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add Docker's APT repository
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package index again
apt-get update

# Install Docker CE
apt-get install -y docker-ce

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply executable permissions to the binary
chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
zip --version

# Create Docker network
docker network create backboneNetwork
EOF
