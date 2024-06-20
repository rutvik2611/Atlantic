#!/bin/bash

# Set variables for remote server
DROPLET_IP="rutvik2611.com"       # Replace with your droplet's IP address or domain
DROPLET_USER="root"               # Replace with your droplet's SSH username if different
REMOTE_DIR="/app/development"     # Remote directory where files will be copied

# Find the 'development' directory locally
LOCAL_DIR=$(find . -type d -name "development" -print -quit)

# Check if 'development' directory is found
if [ -z "${LOCAL_DIR}" ]; then
    echo "Local directory 'development' not found."
    exit 1
fi

# Check if there are files to copy
files_to_copy=$(find "${LOCAL_DIR}" -mindepth 1 -print -quit 2>/dev/null)
if [ -z "${files_to_copy}" ]; then
    echo "No files found in '${LOCAL_DIR}'."
    exit 1
fi

# Copy files to remote server using scp, overwrite existing files
scp -r "${LOCAL_DIR}"/* "${DROPLET_USER}@${DROPLET_IP}:${REMOTE_DIR}/"

# Check if scp command succeeded
if [ $? -ne 0 ]; then
    echo "Copying files failed." >&2
    exit 1
fi

# Echo completion message
echo "Files from '${LOCAL_DIR}' copied successfully to '${DROPLET_IP}:${REMOTE_DIR}' on the remote server."
