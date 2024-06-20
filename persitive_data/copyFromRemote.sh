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

# Create a temporary zip file name
TIMESTAMP=$(date +%Y%m%d%H%M%S)
ZIP_FILE="/tmp/data_${TIMESTAMP}.zip"

# Zip files on remote server
ssh "${DROPLET_USER}@${DROPLET_IP}" "cd ${REMOTE_DIR} && zip -r ${ZIP_FILE} *"

# Check if zip command succeeded remotely
if [ $? -ne 0 ]; then
    echo "Remote zipping failed." >&2
    exit 1
fi

# Copy zip file from remote server to local directory of the script
scp "${DROPLET_USER}@${DROPLET_IP}:${ZIP_FILE}" "${SCRIPT_DIR}/"

# Check if scp command succeeded
if [ $? -ne 0 ]; then
    echo "Copying zip file failed." >&2
    exit 1
fi

# Unzip files locally, overwriting existing files
unzip -o "${SCRIPT_DIR}/$(basename "${ZIP_FILE}")" -d "${SCRIPT_DIR}/"

# Check if unzip command succeeded
if [ $? -ne 0 ]; then
    echo "Unzipping files failed." >&2
    exit 1
fi

# Remove the zip file locally
rm "${SCRIPT_DIR}/$(basename "${ZIP_FILE}")"

# Echo completion message
echo "Files from '${DROPLET_IP}:${REMOTE_DIR}' zipped, copied, unzipped, and cleaned up successfully in '${SCRIPT_DIR}' on the local machine."
