#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Set variables for remote server
DROPLET_IP="rutvik2611.com"       # Replace with your droplet's IP address or domain
DROPLET_USER="root"               # Replace with your droplet's SSH username if different
REMOTE_DIR="/app/persist"         # Remote directory whose contents will be copied

# Check if the remote directory exists
ssh "${DROPLET_USER}@${DROPLET_IP}" "[ -d ${REMOTE_DIR} ]"
if [ $? -ne 0 ]; then
    echo "Remote directory '${REMOTE_DIR}' not found or inaccessible."
    exit 1
fi

# Create a temporary tar.gz file name
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TAR_FILE="/tmp/data_${TIMESTAMP}.tar.gz"

# Create tar.gz archive on remote server, excluding unreadable files
tar_cmd="cd ${REMOTE_DIR} && tar czf ${TAR_FILE} . --exclude='*.zip' --exclude='*.gz' --exclude='./qbittorrent/config/qBittorrent/ipc-socket'"

# Run the tar command and capture the output
tar_output=$(ssh "${DROPLET_USER}@${DROPLET_IP}" "${tar_cmd}" 2>&1)

# Check if tar command succeeded remotely
if [ $? -ne 0 ]; then
    echo "Remote archiving failed: ${tar_output}" >&2
    exit 1
fi

# Check for any warnings about unreadable files
if echo "${tar_output}" | grep -qi "tar: .* Cannot stat"; then
    echo "Warning: Some files could not be read or accessed during archiving, but archiving completed."
fi

# Copy tar.gz file from remote server to local directory of the script
scp "${DROPLET_USER}@${DROPLET_IP}:${REMOTE_DIR}/${TAR_FILE}" "${SCRIPT_DIR}/"

# Check if scp command succeeded
if [ $? -ne 0 ]; then
    echo "Copying tar.gz file failed." >&2
    exit 1
fi

# Unzip files locally, overwriting existing files
tar -xzf "${SCRIPT_DIR}/$(basename "${TAR_FILE}")" -C "${SCRIPT_DIR}/"

# Check if tar command succeeded
if [ $? -ne 0 ]; then
    echo "Extracting files from tar.gz failed." >&2
    exit 1
fi

# Remove the tar.gz file locally
rm "${SCRIPT_DIR}/$(basename "${TAR_FILE}")"

# Echo completion message
echo "Files from '${DROPLET_IP}:${REMOTE_DIR}' archived, copied, extracted, and cleaned up successfully in '${SCRIPT_DIR}' on the local machine."
