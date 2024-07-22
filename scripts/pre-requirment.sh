#!/bin/bash

# Function to check the last command status and exit if it failed
check_status() {
    if [ $? -ne 0 ]; then
        echo "$1 failed." >&2
        exit 1
    fi
}

# Update package lists and upgrade all packages
echo "Updating package lists and upgrading packages..."
sudo apt-get update && sudo apt-get upgrade -y
check_status "System update and upgrade"

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
check_status "Installing necessary packages"

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
check_status "Adding Docker GPG key"

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
check_status "Adding Docker repository"

sudo apt-get update
check_status "Updating package lists for Docker"

sudo apt-get install -y docker-ce
check_status "Installing Docker"

# Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl start docker
check_status "Starting Docker service"

sudo systemctl enable docker
check_status "Enabling Docker service"

# Create a Docker network
echo "Creating Docker network..."
sudo docker network create backboneNetwork
check_status "Creating Docker network"

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
check_status "Downloading Docker Compose"

sudo chmod +x /usr/local/bin/docker-compose
check_status "Applying executable permissions to Docker Compose"

# Add current user to docker group
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER
check_status "Adding user to docker group"

# Install additional useful packages
echo "Installing additional useful packages..."
sudo apt-get install -y git vim ufw zip
check_status "Installing additional packages"

# Setup UFW (Uncomplicated Firewall)
echo "Setting up UFW (Uncomplicated Firewall)..."
sudo ufw allow OpenSSH
check_status "Allowing OpenSSH through UFW"

sudo ufw --force enable
check_status "Enabling UFW"

# Print completion message
echo "Environment setup completed. Please log out and log back in for group changes to take effect."
