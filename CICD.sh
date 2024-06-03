#!/bin/bash

## Make both scripts executable
#chmod +x build_and_push_dockerimage.sh
#chmod +x pull_and_deploy.sh

# Run the first shell script
./build_and_push_dockerimage.sh

# Check the exit status of the first script
if [ $? -eq 0 ]; then
    echo "First script executed successfully."

    # Run the second shell script if the first one succeeded
    ./pull_and_deploy.sh
else
    echo "Error: First script failed. Exiting without running the second script."
    exit 1
fi
