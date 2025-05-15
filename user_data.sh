#!/usr/bin/bash
set -e  # Exit immediately if any command fails

# Update and install required packages if not installed
for package in apache2 git awscli; do
    if ! dpkg -l | grep -qw "$package"; then
        echo "Installing $package..."
        sudo apt update -y
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Optional: Setup SSH keys for GitHub if not already configured
# SSH_KEY="/home/ubuntu/.ssh/id_rsa"
# if [ ! -f "$SSH_KEY" ]; then
#     mkdir -p /home/ubuntu/.ssh
#     aws secretsmanager get-secret-value --secret-id github_ssh_private_key --query SecretString --output text > "$SSH_KEY"
#     sudo chmod 600 "$SSH_KEY"
#     sudo chown ubuntu:ubuntu "$SSH_KEY"
#     eval "$(ssh-agent -s)"
#     ssh-add "$SSH_KEY"
#     ssh-keyscan github.com | sudo tee -a /home/ubuntu/.ssh/known_hosts
#     sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/known_hosts
# fi

# Define the path to the SSH private key
SSH_KEY="/home/ubuntu/.ssh/id_rsa"

# Check if the SSH key already exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Setting up SSH key for GitHub access..."

    # Create the .ssh directory with appropriate permissions
    mkdir -p /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh
    chown ubuntu:ubuntu /home/ubuntu/.ssh

    # Retrieve the SSH private key from AWS Secrets Manager
    aws secretsmanager get-secret-value --secret-id github_ssh_private_key --query SecretString --output text > "$SSH_KEY"

    # Set the correct permissions for the private key
    chmod 600 "$SSH_KEY"
    chown ubuntu:ubuntu "$SSH_KEY"

    # Start the SSH agent and add the private key
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"

    # Add GitHub to known_hosts to prevent SSH prompts
    ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts
    chmod 644 /home/ubuntu/.ssh/known_hosts
    chown ubuntu:ubuntu /home/ubuntu/.ssh/known_hosts

    echo "SSH key setup complete."
else
    echo "SSH key already exists. Skipping setup."
fi

# Clone the repository as the ubuntu user
WEB_DIR="/var/www/html"
echo "Clearing existing content from $WEB_DIR..."
sudo rm -rfv "$WEB_DIR"/*
echo "Cloning repository into $WEB_DIR..."
git clone git@github.com:omokarogabriel/my-port-folio.git "$WEB_DIR"

# Set proper permissions
sudo chown -R www-data:www-data "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "Deployment complete! Your site should be live."



