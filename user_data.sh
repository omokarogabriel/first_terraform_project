
#!/usr/bin/bash
set -e

# Update and install required packages
sudo apt-get update -y
sudo apt-get install -y apache2 git awscli

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Define variables
SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
WEB_DIR="/var/www/html"

# Create .ssh directory
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chown ubuntu:ubuntu /home/ubuntu/.ssh

# Retrieve SSH private key from AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id github_ssh_private_key --query SecretString --output text > "$SSH_KEY_PATH"
chmod 600 "$SSH_KEY_PATH"
chown ubuntu:ubuntu "$SSH_KEY_PATH"

# Start SSH agent and add the key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

# Add GitHub to known_hosts
ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"

# Clone the private GitHub repository
rm -rf "${WEB_DIR:?}"/*
git clone git@github.com:omokarogabriel/my-port-folio.git "$WEB_DIR"

# Set proper permissions
chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "Deployment complete! Your site should be live."
