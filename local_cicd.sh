#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Create local emulation directory
mkdir -p "$(pwd)/emulating_server/app/development"

# Copy files to local emulation directory
cp -R ./development/* "$(pwd)/emulating_server/app/development/"

# Run Docker Compose
docker-compose down
docker-compose up -d