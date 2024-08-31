#!/bin/bash

# Load environment variables from .env file, if it exists
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Create local emulation directory if it does not exist
mkdir -p "$(pwd)/emulating_server/app/development"

# Synchronize files from the development directory to the local emulation directory
# Exclude the persist folder to avoid touching it
rsync -av --delete --exclude 'persist' ./development/ "$(pwd)/emulating_server/app/development/"

# Change to the emulation directory
cd "$(pwd)/emulating_server/app/development/"

# Loop through all .yml files and perform docker-compose commands
for yml_file in *.yml; do
    if [ -f "$yml_file" ]; then
        # Stop all running services defined in the Docker Compose file
        docker-compose -f "$yml_file" down
    fi
done

# Remove orphan containers that are not defined in the Docker Compose files
docker container prune -f

# Remove all stopped containers to ensure no orphan containers remain
docker rm -f $(docker ps -aq) 2>/dev/null

# Loop through all .yml files again to start services
for yml_file in *.yml; do
    if [ -f "$yml_file" ]; then
        # Start all services in detached mode
        docker-compose -f "$yml_file" up -d
    fi
done
