#!/bin/bash

# Set variables
IMAGE_NAME="atlantic"
DOCKERHUB_USERNAME="temp12611"
DOCKERHUB_REPO="atlantic"
TAG="latest"
DROPLET_IP="rutvik2611.com" # Replace with your droplet's IP address or domain
DROPLET_USER="root" # Replace with your droplet's SSH username if different

# Function to check the last command status and exit if it failed
check_status() {
    if [ $? -ne 0 ]; then
        echo "$1 failed." >&2
        exit 1
    fi
}

# Echo connecting to the droplet
echo "Connecting to the DigitalOcean droplet and deploying the latest Docker image..."

docker_run_cmd_print="docker run -v /var/run/docker.sock:/var/run/docker.sock -p 80:80 -p 443:443 -p 8080:8080 ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${TAG}"
echo "docker rm -f \$(docker ps -aq)"
echo "${docker_run_cmd_print}"

# SSH into the droplet, pull the latest image, and run it
ssh ${DROPLET_USER}@${DROPLET_IP} << EOF
    echo "Pulling the latest Docker image..."
    docker pull ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${TAG}
    if [ \$? -ne 0 ]; then
        echo "Docker image pull failed." >&2
        exit 1
    fi

    # Stop and remove all existing containers
    echo "Stopping and removing all existing containers..."
    docker rm -f \$(docker ps -aq)

    # Stop and remove the specified container (if exists)
    echo "Stopping and removing any existing container..."
    docker rm -f ${IMAGE_NAME} || true
    if [ \$? -ne 0 ]; then
        echo "Stopping existing container failed." >&2
        exit 1
    fi

    # Construct the Docker run command
    docker_run_cmd="docker run -d --name ${IMAGE_NAME} -v /var/run/docker.sock:/var/run/docker.sock ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${TAG}"
    echo 'Running the new container with command: $docker_run_cmd'

    # Run the Docker container
    \$docker_run_cmd
    if [ \$? -ne 0 ]; then
        echo "Running new container failed." >&2
        docker logs ${IMAGE_NAME}
        exit 1
    else
        echo "New container deployed successfully."
        docker ps
    fi
EOF

check_status "Deployment to droplet"

# Echo completion message
echo "Docker image pull, deployment, and log retrieval completed."
