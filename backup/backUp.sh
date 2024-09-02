#!/bin/bash

# SSH connection details
SSH_USER="root"
SSH_HOST="rutvik2611.com"
REMOTE_PERSIST_DIR="/app/development/persist"
LOCAL_BACKUP_DIR="$(pwd)/prod-backup/persist"
SIZE_THRESHOLD_MB=70  # Size threshold in MB

# Ensure the backup directory exists locally
mkdir -p "$LOCAL_BACKUP_DIR"

# Function to format size in human-readable format
format_size() {
    local size=$1
    echo $(numfmt --to=iec-i --suffix=B $size)
}

# Function to compress and backup a folder
backup_folder() {
    local folder_name=$1

    echo "Compressing and backing up folder '$folder_name'..."

    # Create a zip file of the directory on the remote server
    ssh $SSH_USER@$SSH_HOST "cd $REMOTE_PERSIST_DIR && zip -r ${folder_name}.zip $folder_name"

    # Attempt to copy the zip file from the remote server to the local backup directory
    scp "$SSH_USER@$SSH_HOST:$REMOTE_PERSIST_DIR/${folder_name}.zip" "$LOCAL_BACKUP_DIR/"
    if [ $? -eq 0 ]; then
        echo "Zip file '$folder_name.zip' copied successfully."

        # Unzip the copied file locally
        unzip -o "$LOCAL_BACKUP_DIR/${folder_name}.zip" -d "$LOCAL_BACKUP_DIR/"

        # Clean up the zip files locally and remotely
        rm "$LOCAL_BACKUP_DIR/${folder_name}.zip"
        ssh $SSH_USER@$SSH_HOST "rm $REMOTE_PERSIST_DIR/${folder_name}.zip"
        echo "Backup of folder '$folder_name' completed successfully."
    else
        echo "Failed to copy the zip file. Trying individual files..."

        # Attempt to back up individual files if zip fails
        rsync -avz --delete "$SSH_USER@$SSH_HOST:$REMOTE_PERSIST_DIR/$folder_name/" "$LOCAL_BACKUP_DIR/$folder_name/"

        if [ $? -eq 0 ]; then
            echo "Individual file backup for folder '$folder_name' completed successfully."
        else
            echo "Failed to backup individual files for folder '$folder_name'. Please check the connection and try again."
        fi
    fi
}

# Function to handle subfolder backup
backup_subfolder() {
    local parent_folder=$1
    local subfolder_name=$2

    echo "Checking size of subfolder '$subfolder_name'..."
    subfolder_path="$REMOTE_PERSIST_DIR/$parent_folder/$subfolder_name"
    subfolder_size=$(ssh $SSH_USER@$SSH_HOST "du -sb $subfolder_path | cut -f1")
    subfolder_size_mb=$(echo "scale=2; $subfolder_size / 1048576" | bc)
    formatted_size=$(format_size $subfolder_size)

    if (( $(echo "$subfolder_size_mb > $SIZE_THRESHOLD_MB" | bc -l) )); then
        echo "Subfolder '$subfolder_name' is $formatted_size (approximately $subfolder_size_mb MB)."
        read -p "Do you want to back up the subfolder '$subfolder_name'? (y/n): " user_input
        if [[ "$user_input" =~ ^[Yy]$ ]]; then
            backup_folder "$parent_folder/$subfolder_name"
        else
            echo "Skipping subfolder '$subfolder_name'."
        fi
    else
        echo "Subfolder '$subfolder_name' is $formatted_size (approximately $subfolder_size_mb MB). Automatically backing up..."
        backup_folder "$parent_folder/$subfolder_name"
    fi
}

# Function to prompt user for folder backup
prompt_user_for_backup() {
    local folder_name=$1
    local folder_size_mb=$2
    local formatted_size=$3

    echo "Folder '$folder_name' is $formatted_size (approximately $folder_size_mb MB)."

    # Ask user if they want to back up this folder
    read -p "The folder '$folder_name' is larger than $SIZE_THRESHOLD_MB MB. Do you want to back it up? (y/n): " user_input
    if [[ "$user_input" =~ ^[Yy]$ ]]; then
        backup_folder "$folder_name"
    else
        echo "Skipping folder '$folder_name'."
        # Automatically back up subfolders if user skipped the main folder
        echo "Checking and backing up subfolders of '$folder_name'..."
        subfolders=$(ssh $SSH_USER@$SSH_HOST "ls -d $REMOTE_PERSIST_DIR/$folder_name/*/")
        for subfolder in $subfolders; do
            subfolder_name=$(basename "$subfolder")
            backup_subfolder "$folder_name" "$subfolder_name"
        done
    fi
}

# List all folders in the remote 'persist' directory
echo "Fetching folder list from remote persist directory..."
REMOTE_FOLDERS=$(ssh $SSH_USER@$SSH_HOST "ls -d $REMOTE_PERSIST_DIR/*/" 2>/dev/null)

if [ -z "$REMOTE_FOLDERS" ]; then
    echo "No folders found in the remote persist directory."
    exit 1
fi

# Process each folder
echo "Folders found in remote persist directory:"
for folder in $REMOTE_FOLDERS; do
    folder_name=$(basename "$folder")

    # Check the size of the folder
    folder_size=$(ssh $SSH_USER@$SSH_HOST "du -sb $REMOTE_PERSIST_DIR/$folder_name | cut -f1")
    folder_size_mb=$(echo "scale=2; $folder_size / 1048576" | bc)
    formatted_size=$(format_size $folder_size)

    if (( $(echo "$folder_size_mb > $SIZE_THRESHOLD_MB" | bc -l) )); then
        prompt_user_for_backup "$folder_name" "$folder_size_mb" "$formatted_size"
    else
        echo "Folder '$folder_name' is $formatted_size (approximately $folder_size_mb MB). Automatically backing up..."
        backup_folder "$folder_name"
    fi
done

echo "Backup process completed."
