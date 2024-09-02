#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_DIR="/app/development"
LOCAL_DIR="./development"
ENV_FILE="remote.env"  # Change this if you want to use a different env file
EXCLUDE_DIR="persist"  # Directory to exclude during rsync

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

# Copy the local ENV file to the remote machine
echo "Copying environment file to remote machine..."
scp "$ENV_FILE" "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"
echo "Environment file copied to remote machine."

# Load environment variables and perform Docker operations in a single SSH session
echo "Loading environment variables from remote $ENV_FILE and managing Docker services..."
ssh $SSH_USER@$SSH_HOST <<EOF
    # Load environment variables from the copied ENV file
    if [ -f "$REMOTE_DIR/$ENV_FILE" ]; then
        echo "Loading environment variables from $REMOTE_DIR/$ENV_FILE:"
        export \$(cat $REMOTE_DIR/$ENV_FILE | xargs)
        while IFS= read -r line; do
            var_name=\$(echo "\$line" | cut -d '=' -f 1)
            echo "Loaded variable: \$var_name=\${\$var_name}"
        done < $REMOTE_DIR/$ENV_FILE
    else
        echo "No environment variables file found at $REMOTE_DIR/$ENV_FILE."
    fi

    # Change to the remote directory
    cd $REMOTE_DIR
    echo "Changed directory to $REMOTE_DIR."

    # Stop all running services defined in the Docker Compose files
    for yml_file in *.yml; do
        if [ -f "\$yml_file" ]; then
            echo "Stopping services defined in \$yml_file..."
            docker-compose -f "\$yml_file" down
        else
            echo "No Docker Compose file found: \$yml_file"
        fi
    done

    # Remove orphan containers that are not defined in the Docker Compose files
    echo "Removing orphan containers..."
    docker container prune -f
    echo "Orphan containers removed."

    # Remove all stopped containers to ensure no orphan containers remain
    echo "Removing all stopped containers..."
    docker rm -f \$(docker ps -aq) 2>/dev/null
    echo "Stopped containers removed."

    # Start services defined in the Docker Compose files
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

# kill all containers - docker rm $(docker ps -a -q)

