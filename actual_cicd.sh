#!/bin/bash

# Print current working directory
echo "Current working directory: $(pwd)"

# Load environment variables from .env file
set -a
source .env || { echo "Error: .env file not found."; exit 1; }
set +a

# Function to deploy Docker containers
deploy_docker() {
    echo "Searching for Docker Compose files in ${REMOTE_DIR}/development..."
    local docker_files=$(ssh "${REMOTE_USER}@${REMOTE_HOST}" "find ${REMOTE_DIR}/development -name 'docker-compose*.yml' -type f")
    
    if [ -z "$docker_files" ]; then
        echo "No Docker Compose files found in ${REMOTE_DIR}/development."
        return 1
    fi
    
    echo "Found Docker Compose files:"
    echo "$docker_files"
    
    # Export all environment variables
    local env_vars=$(printenv | awk -F= '{print "export " $1 "=\"" $2 "\""}')
    
    # Deploy each Docker Compose file
    for file in $docker_files; do
        echo "Deploying Docker Compose file: $file"
        ssh "${REMOTE_USER}@${REMOTE_HOST}" "cd $(dirname $file) && \
            $env_vars && \
            echo 'Stopping existing containers...' && \
            docker-compose -f $(basename $file) down && \
            echo 'Starting new containers...' && \
            docker-compose -f $(basename $file) up -d" && \
        echo "Deployment of $file completed successfully."
    done
}

# Main logic
echo "Starting actual CICD process"
deploy_docker
echo "Actual CICD process completed"
echo "Summary of actions:"
echo "- Docker containers deployed from all docker-compose*.yml files in ${REMOTE_DIR}/development"
echo "All tasks completed. Actual CICD finished."
