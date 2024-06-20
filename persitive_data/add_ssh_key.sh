#!/bin/bash

# Provide examples of what to copy for clarity
echo "Example of what to copy for the SSH public key (.pub file):"
echo "================================"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtP6vzJZVUNZs8Uq4N7Hk0Y5g1t5QbLgAmoW4TYSaWcR0jEzGqZ7nlJf7VCM+InhOZ1+rfV2Fphj+3i7A+Uf7B2Rbb3Mev2DfL54JS04b8zC7n6JbcN0DkE9f3sPQhUjBGLKj3V4gXylohNw6Tg6AuX9BYCCX/2OVKfWosYh2CvOGY4Q+adI7bKTwC0N9sPK5Pr8NR0b9H9d8FUTbU8UXG9OnuW5EKD2F+I5DYAXZK39Ox5U9gG5w7wS66nA8zF6w/7+xCyPT2JFg3hbb0i/0Q5N2GL/FWhwB6JgS8oNfruHFLtfn9dH32n4eJZPtkWb1mYenikn/4w4Z0qNww== user@hostname"
echo "================================"
echo
echo "Example of what to copy for the SSH private key:"
echo "================================"
echo "-----BEGIN RSA PRIVATE KEY-----"
echo "MIIEogIBAAKCAQEAtP6vzJZVUNZs8Uq4N7Hk0Y5g1t5QbLgAmoW4TYSaWcR0jEzG"
echo "qZ7nlJf7VCM+InhOZ1+rfV2Fphj+3i7A+Uf7B2Rbb3Mev2DfL54JS04b8zC7n6Jb"
echo "cN0DkE9f3sPQhUjBGLKj3V4gXylohNw6Tg6AuX9BYCCX/2OVKfWosYh2CvOGY4Q+"
echo "adI7bKTwC0N9sPK5Pr8NR0b9H9d8FUTbU8UXG9OnuW5EKD2F+I5DYAXZK39Ox5U9"
echo "gG5w7wS66nA8zF6w/7+xCyPT2JFg3hbb0i/0Q5N2GL/FWhwB6JgS8oNfruHFLtfn"
echo "9dH32n4eJZPtkWb1mYenikn/4w4Z0qNww=="
echo "-----END RSA PRIVATE KEY-----"
echo "================================"
echo

# Prompt user for the content of the public key (.pub file)
echo "Please paste the content of your SSH public key (.pub file) and press Enter:"
read public_key_content

# Prompt user for the content of the private key file
echo "Please paste the content of your SSH private key file and press Enter:"
read private_key_content

# Create SSH directory if it doesn't exist
mkdir -p ~/.ssh

# Set permissions for the SSH directory and authorized_keys file
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Append the public key content to the authorized_keys file
echo "$public_key_content" >> ~/.ssh/authorized_keys

# Save the private key content to a file (optional, only if needed)
echo "$private_key_content" > ~/.ssh/id_rsa

# Set permissions for the private key file
chmod 600 ~/.ssh/id_rsa

# Inform the user that the SSH key has been added
echo "SSH key has been added to your system."
