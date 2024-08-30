#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST=rutvik2611.com

# Remote commands
ssh $SSH_USER@$SSH_HOST << EOF
    # Load environment variables
    if [ -f .env ]; then
        export $(cat .env | xargs)
    fi

    # Create remote directory
    mkdir -p /app/development

    # Copy files to remote directory
    scp -r ./development/* $SSH_USER@$SSH_HOST:/app/development/

    # Run Docker Compose
    docker-compose down
    docker-compose up -d
EOF