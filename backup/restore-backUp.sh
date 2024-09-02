#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_PERSIST_DIR="/app/development-pending-xxxx/persist"
LOCAL_BACKUP_DIR="$(pwd)/prod-backup/persist"

# Function to handle the restoration process
restore_folder() {
    local folder_name=$1
    local local_folder="$LOCAL_BACKUP_DIR/$folder_name"
    local local_zip="$LOCAL_BACKUP_DIR/$folder_name.zip"
    local remote_path="$REMOTE_PERSIST_DIR/$folder_name"

    echo "Restoring folder '$folder_name'..."

    # Zip the local folder
    echo "Creating zip file '$local_zip'..."
    if ! zip -r "$local_zip" "$local_folder"; then
        echo "Failed to create zip file '$local_zip'."
        return
    fi

    # Check if remote directory exists
    if ssh "$SSH_USER@$SSH_HOST" "test -d '$remote_path'"; then
        echo "Remote path '$remote_path' already exists."
        read -p "The path '$remote_path' already exists. Do you want to overwrite it with new data? (y/n): " overwrite
        if [ "$overwrite" != "y" ]; then
            echo "Skipping '$folder_name' restoration."
            rm "$local_zip"
            return
        fi
        echo "Overwriting existing data in '$remote_path'..."
    fi

    # Transfer the zip file
    echo "Transferring zip file '$local_zip'..."
    if ! scp "$local_zip" "$SSH_USER@$SSH_HOST:$REMOTE_PERSIST_DIR/"; then
        echo "Failed to transfer zip file '$local_zip'."
        rm "$local_zip"
        return
    fi

    # Extract the zip file on the remote server
    echo "Extracting zip file on remote server..."
    if ! ssh "$SSH_USER@$SSH_HOST" "unzip -o '$REMOTE_PERSIST_DIR/$folder_name.zip' -d '$REMOTE_PERSIST_DIR/$folder_name'"; then
        echo "Failed to extract zip file '$folder_name.zip' on remote server."
        rm "$local_zip"
        return
    fi

    # Remove the zip file from the remote server
    echo "Removing zip file from remote server..."
    if ! ssh "$SSH_USER@$SSH_HOST" "rm '$REMOTE_PERSIST_DIR/$folder_name.zip'"; then
        echo "Failed to remove zip file '$folder_name.zip' from remote server."
        # Attempt to remove local zip file even if remote zip removal failed
        rm "$local_zip"
        return
    fi

    # Remove the local zip file
    echo "Removing local zip file '$local_zip'..."
    rm "$local_zip"

    echo "Folder '$folder_name' restored successfully."
}

# Main script
echo "Fetching list of backup folders..."
folders=$(ls "$LOCAL_BACKUP_DIR" | grep -E '^[^\.]+$') # Only folders, exclude hidden or non-folder files

if [ -z "$folders" ]; then
    echo "No folders found in local backup directory."
    exit 1
fi

echo "Folders found in local backup directory:"
for folder in $folders; do
    echo "- $folder"
done

for folder in $folders; do
    read -p "Do you want to restore the folder '$folder' from the backup? (y/n): " restore
    if [ "$restore" == "y" ]; then
        restore_folder "$folder"
    fi
done

echo "Restore process completed."
