#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_PERSIST_DIR="/app/test/persist"
LOCAL_BACKUP_DIR="$(pwd)/prod-backup/persist"

# Function to restore a folder
restore_folder() {
    local folder_name=$1
    local remote_path="$REMOTE_PERSIST_DIR/$folder_name"
    local local_zip="$LOCAL_BACKUP_DIR/${folder_name}.zip"

    echo "Restoring folder '$folder_name'..."

    # Check if the remote path exists
    remote_exists=$(ssh $SSH_USER@$SSH_HOST "test -d $remote_path && echo 'yes' || echo 'no'")

    if [ "$remote_exists" == "no" ]; then
        echo "Remote path '$remote_path' does not exist. Creating it..."
        ssh $SSH_USER@$SSH_HOST "mkdir -p $remote_path"
    else
        echo "Remote path '$remote_path' already exists."

        # Ask user if they want to overwrite existing data
        read -p "The path '$remote_path' already exists. Do you want to overwrite it with new data? (y/n): " user_input
        if [[ "$user_input" =~ ^[Yy]$ ]]; then
            echo "Overwriting existing data in '$remote_path'..."

            # Remove existing data if user agrees
            ssh $SSH_USER@$SSH_HOST "rm -rf $remote_path/*"
        else
            echo "Skipping overwrite for '$remote_path'."
            return
        fi
    fi

    # Check if the zip file exists locally before attempting to transfer
    if [ ! -f "$local_zip" ]; then
        echo "Local zip file '$local_zip' does not exist. Skipping restoration."
        return
    fi

    # Transfer the zip file from the local backup directory to the remote server
    scp "$local_zip" "$SSH_USER@$SSH_HOST:$REMOTE_PERSIST_DIR/"
    if [ $? -eq 0 ]; then
        echo "Zip file '${folder_name}.zip' transferred successfully."

        # Unzip the file on the remote server
        ssh $SSH_USER@$SSH_HOST "cd $REMOTE_PERSIST_DIR && unzip -o ${folder_name}.zip -d $folder_name"

        # Ensure the zip file was created successfully and is available before attempting to delete
        zip_file_exists=$(ssh $SSH_USER@$SSH_HOST "test -f $REMOTE_PERSIST_DIR/${folder_name}.zip && echo 'yes' || echo 'no'")
        if [ "$zip_file_exists" == "yes" ]; then
            echo "Zip file '${folder_name}.zip' found on remote server. Removing it..."
            ssh $SSH_USER@$SSH_HOST "rm -f $REMOTE_PERSIST_DIR/${folder_name}.zip"
            if [ $? -eq 0 ]; then
                echo "Zip file '${folder_name}.zip' removed from remote server."
            else
                echo "Failed to remove zip file '${folder_name}.zip' from remote server."
            fi
        else
            echo "No zip file '${folder_name}.zip' found on remote server for removal."
        fi

        echo "Folder '$folder_name' restored successfully."
    else
        echo "Failed to transfer the zip file '${folder_name}.zip'."
    fi
}

# Ensure the backup directory exists locally
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
    echo "Local backup directory '$LOCAL_BACKUP_DIR' does not exist."
    exit 1
fi

# List all zip files in the local backup directory
echo "Fetching list of backup zip files..."
ZIP_FILES=$(ls "$LOCAL_BACKUP_DIR"/*.zip 2>/dev/null)

if [ -z "$ZIP_FILES" ]; then
    echo "No backup zip files found in the local backup directory."
    exit 1
fi

# Prompt the user for each zip file if they want to restore it
echo "Backup zip files found in local backup directory:"
for zip_file in $ZIP_FILES; do
    folder_name=$(basename "$zip_file" .zip)

    # Ask user if they want to restore this folder
    read -p "Do you want to restore the folder '$folder_name' from the backup? (y/n): " user_input
    if [[ "$user_input" =~ ^[Yy]$ ]]; then
        restore_folder "$folder_name"
    else
        echo "Skipping restoration of folder '$folder_name'."
    fi
done

echo "Restore process completed."
