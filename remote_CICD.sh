#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_DIR="/app/development"
LOCAL_DIR="./development"
ENV_FILE="remote.env"  # Change this if you want to use a different env file
EXCLUDE_DIR="persist"  # Directory to exclude during rsync

# Load environment variables from local.env file, if it exists
echo "Checking for environment file: $ENV_FILE"
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | xargs)
    echo "Environment variables loaded from $ENV_FILE."
else
    echo "Error: $ENV_FILE file not found."
    exit 1
fi

# Check if the remote directory exists and create it if necessary
echo "Checking if remote directory exists: $REMOTE_DIR"
ssh $SSH_USER@$SSH_HOST <<EOF
    if [ ! -d "$REMOTE_DIR" ]; then
        echo "Directory $REMOTE_DIR does not exist. Creating it..."
        mkdir -p "$REMOTE_DIR"
    else
        echo "Directory $REMOTE_DIR already exists."
    fi
EOF

# Synchronize files from the local development directory to the remote directory
echo "Synchronizing files from $LOCAL_DIR to $REMOTE_DIR on remote host..."
rsync -av --delete --exclude "$EXCLUDE_DIR" "$LOCAL_DIR/" "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"
echo "File synchronization completed."

# Load environment variables from .env file, if it exists on the remote server
echo "Loading environment variables from remote .env file..."
ssh $SSH_USER@$SSH_HOST <<EOF
    if [ -f "/app/development/.env" ]; then
        export \$(cat /app/development/.env | xargs)
        echo "Environment variables loaded from /app/development/.env."
    else
        echo "No environment variables file found at /app/development/.env."
    fi
EOF

# Change to the remote directory
echo "Changing to remote directory: /app/development"
ssh $SSH_USER@$SSH_HOST <<EOF
    cd /app/development
    echo "Changed directory to /app/development."
EOF

# Stop all running services defined in the Docker Compose files
echo "Stopping running services defined in Docker Compose files..."
ssh $SSH_USER@$SSH_HOST <<EOF
    for yml_file in *.yml; do
        if [ -f "\$yml_file" ]; then
            echo "Stopping services defined in \$yml_file..."
            docker-compose -f "\$yml_file" down
        else
            echo "No Docker Compose file found: \$yml_file"
        fi
    done
EOF

# Remove orphan containers that are not defined in the Docker Compose files
echo "Removing orphan containers..."
ssh $SSH_USER@$SSH_HOST <<EOF
    docker container prune -f
    echo "Orphan containers removed."
EOF

# Remove all stopped containers to ensure no orphan containers remain
echo "Removing all stopped containers..."
ssh $SSH_USER@$SSH_HOST <<EOF
    docker rm -f \$(docker ps -aq) 2>/dev/null
    echo "Stopped containers removed."
EOF

# Start services defined in the Docker Compose files
echo "Starting services defined in Docker Compose files..."
ssh $SSH_USER@$SSH_HOST <<EOF
    for yml_file in *.yml; do
        if [ -f "\$yml_file" ]; then
            echo "Starting services defined in \$yml_file..."
            docker-compose -f "\$yml_file" up -d
        else
            echo "No Docker Compose file found: \$yml_file"
        fi
    done
EOF

echo "Docker containers deployed successfully on remote machine."
