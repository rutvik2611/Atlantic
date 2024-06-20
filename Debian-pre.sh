#!/bin/bash

# Function to check the last command status and continue if it failed
check_status() {
    if [ $? -ne 0 ]; then
        echo "$1 failed." >&2
        # Print an error message but continue script execution
        return 1
    fi
    return 0
}

# Function to ask yes/no questions
ask_yes_no() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Update package lists and upgrade all packages
echo "Updating package lists and upgrading packages..."
sudo apt-get update && sudo apt-get upgrade -y
check_status "System update and upgrade"

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2
check_status "Installing necessary packages"

# Install Docker
echo "Installing Docker..."

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
check_status "Adding Docker GPG key"

# Set up stable repository for Docker
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
check_status "Adding Docker repository"

# Update package lists for Docker
sudo apt-get update
check_status "Updating package lists for Docker"

# Install Docker engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
check_status "Installing Docker"

# Check if Docker network already exists
docker_network="backboneNetwork"
if sudo docker network inspect "$docker_network" >/dev/null 2>&1; then
    echo "Docker network '$docker_network' already exists. Skipping creation."
else
    # Create a Docker network
    echo "Creating Docker network..."
    sudo docker network create "$docker_network"
    check_status "Creating Docker network"
fi

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
if ! check_status "Allowing OpenSSH through UFW"; then
    echo "ERROR: Could not find a profile matching 'OpenSSH'. Allowing OpenSSH through UFW failed."
fi

sudo ufw --force enable
check_status "Enabling UFW"

# Print completion message
echo "Environment setup completed. Please log out and log back in for group changes to take effect."
