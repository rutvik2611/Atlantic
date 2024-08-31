#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_DIR="/app/development"
LOCAL_DIR="./development"
ENV_FILE="remote.env"  # Change this if you want to use a different env file
EXCLUDE_DIR="persist"  # Directory to exclude during rsync

# Load environment variables from local.env file, if it exists
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | xargs)
    echo "Environment variables loaded from $ENV_FILE."
else
    echo "Error: $ENV_FILE file not found."
    exit 1
fi

# Synchronize files from the local development directory to the remote directory
# Exclude the persist folder to avoid syncing it
rsync -av --delete --exclude "$EXCLUDE_DIR" "$LOCAL_DIR/" "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"

# Define remote commands to be executed one by one
ssh $SSH_USER@$SSH_HOST << 'EOF'
    # Load environment variables from .env file, if it exists on the remote server
    if [ -f "/app/development/.env" ]; then
        export $(cat /app/development/.env | xargs)
        echo "Environment variables loaded from /app/development/.env."
    else
        echo "No environment variables file found at /app/development/.env."
    fi
EOF

ssh $SSH_USER@$SSH_HOST << 'EOF'
    # Change to the remote directory
    cd /app/development
EOF

ssh $SSH_USER@$SSH_HOST << 'EOF'
    # Stop all running services defined in the Docker Compose files
    for yml_file in *.yml; do
        if [ -f "$yml_file" ]; then
            echo "Stopping services defined in $yml_file..."
            docker-compose -f "$yml_file" down
        fi
    done
EOF

ssh $SSH_USER@$SSH_HOST << 'EOF'
    # Remove orphan containers that are not defined in the Docker Compose files
    echo "Removing orphan containers..."
    docker container prune -f
EOF

ssh $SSH_USER@$SSH_HOST << 'EOF'
    # Remove all stopped containers to ensure no orphan containers remain
    echo "Removing all stopped containers..."
    docker rm -f $(docker ps -aq) 2>/dev/null
EOF

ssh $SSH_USER@$SSH_HOST << 'EOF'
    # Start services defined in the Docker Compose files
    for yml_file in *.yml; do
        if [ -f "$yml_file" ]; then
            echo "Starting services defined in $yml_file..."
            docker-compose -f "$yml_file" up -d
        fi
    done
EOF

echo "Docker containers deployed successfully on remote machine."
