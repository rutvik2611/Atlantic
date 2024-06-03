#!/bin/bash

# Set variables
IMAGE_NAME="atlantic"
DOCKERHUB_USERNAME="temp12611"
DOCKERHUB_REPO="atlantic"
TAG="latest"

# Function to check the last command status and exit if it failed
check_status() {
    if [ $? -ne 0 ]; then
        echo "$1 failed." >&2
        exit 1
    fi
}

# Echo starting build process
echo "Starting Docker image build..."

# Build the Docker image
docker build -t ${IMAGE_NAME}:${TAG} .
check_status "Docker image build"

# Echo tagging the image
echo "Tagging the Docker image for Docker Hub..."

# Tag the Docker image for Docker Hub
docker tag ${IMAGE_NAME}:${TAG} ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${TAG}
check_status "Docker image tagging"

# Ensure you are logged in to Docker Hub
echo "Logging in to Docker Hub..."
docker login
check_status "Docker login"

# Echo starting the push process
echo "Pushing the Docker image to Docker Hub..."

# Push the Docker image to Docker Hub
docker push ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${TAG}
check_status "Docker image push"

# Echo completion message
echo "Docker image build and push process completed."
