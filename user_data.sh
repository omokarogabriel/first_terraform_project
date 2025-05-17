#!/bin/bash
set -euo pipefail

# Variables
SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
WEB_DIR="/var/www/html"
PACKAGES=("apache2" "git" "awscli")

# Function to check and install packages
install_packages() {
  for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      echo "Installing $pkg..."
      sudo apt-get update -y
      sudo apt-get install -y "$pkg"
    else
      echo "$pkg is already installed."
    fi
  done
}

# Function to set up SSH key
# setup_ssh_key() {
#   echo "Setting up SSH key..."
#   mkdir -p "$(dirname "$SSH_KEY_PATH")"
#   chmod 700 "$(dirname "$SSH_KEY_PATH")"
#   chown ubuntu:ubuntu "$(dirname "$SSH_KEY_PATH")"

#   #aws secretsmanager get-secret-value --secret-id github_ssh_private_key --query SecretString --output text > "$SSH_KEY_PATH"
#   cp -i /home/omokaro/.ssh/github_key /home/ubuntu/.ssh/id_rsa > "$SSH_KEY_PATH"
#   chmod 600 "$SSH_KEY_PATH"
#   chown ubuntu:ubuntu "$SSH_KEY_PATH"

# #   eval "$(ssh-agent -s)"
# #   ssh-add "$SSH_KEY_PATH"

# #   ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH"
#   chmod 644 "$KNOWN_HOSTS_PATH"
#   chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
# }


# Function to set up SSH key
setup_ssh_key() {
  echo "Setting up SSH key..."
  
  # Create .ssh directory with proper permissions
  mkdir -p "$(dirname "$SSH_KEY_PATH")"
  chmod 700 "$(dirname "$SSH_KEY_PATH")"
  chown ubuntu:ubuntu "$(dirname "$SSH_KEY_PATH")"

  # Copy the SSH private key
  cp /home/omokaro/.ssh/github_key "$SSH_KEY_PATH"
  chmod 600 "$SSH_KEY_PATH"
  chown ubuntu:ubuntu "$SSH_KEY_PATH"

  # Start the SSH agent and add the key
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY_PATH"

  # Add GitHub to known_hosts if not already there
  if ! grep -q "github.com" "$KNOWN_HOSTS_PATH"; then
    ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH"
  fi

  chmod 644 "$KNOWN_HOSTS_PATH"
  chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
}


# Function to deploy GitHub repository
deploy_repository() {
  echo "Deploying GitHub repository..."
  rm -rf "${WEB_DIR:?}"/*
#   git clone git@github.com:omokarogabriel/my-port-folio.git "$WEB_DIR"
  git clone git@github.com:omokarogabriel/portfolio.git "$WEB_DIR"
  chown -R www-data:www-data "$WEB_DIR"
  chmod -R 755 "$WEB_DIR"
}

# Function to start and enable Apache
configure_apache() {
  echo "Configuring Apache..."
  sudo systemctl start apache2
  sudo systemctl enable apache2
}

# Main execution
install_packages
setup_ssh_key
deploy_repository
configure_apache

echo "Deployment complete! Your site should be live."


# #!/bin/bash
# Enable debug mode for easier troubleshooting
# set -euo pipefail

# # Update and install necessary packages
# sudo apt-get update -y
# sudo apt-get install -y git awscli apache2

# # Set up SSH directory
# mkdir -p /home/ubuntu/.ssh
# chmod 700 /home/ubuntu/.ssh
# chown ubuntu:ubuntu /home/ubuntu/.ssh

# # Retrieve the private key from AWS Secrets Manager
# aws secretsmanager get-secret-value \
#   --secret-id github-ssh-key \
#   --query SecretString \
#   --output text > /home/ubuntu/.ssh/id_rsa

# # Set permissions for the SSH key
# chmod 600 /home/ubuntu/.ssh/id_rsa
# chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

# # Add GitHub to known hosts
# ssh-keyscan -t rsa github.com >> /home/ubuntu/.ssh/known_hosts
# chmod 644 /home/ubuntu/.ssh/known_hosts
# chown ubuntu:ubuntu /home/ubuntu/.ssh/known_hosts

# # Create the web directory and set permissions
# sudo mkdir -p /var/www/html
# sudo chown -R ubuntu:ubuntu /var/www/html

# # Clone the private repository
# sudo -u ubuntu git clone git@github.com:omokarogabriel/portfolio.git /var/www/html

# # Set correct permissions for Apache
# sudo chown -R www-data:www-data /var/www/html
# sudo chmod -R 755 /var/www/html





# #!/bin/bash
# set -euo pipefail

# # === VARIABLES ===
# SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
# KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
# SSH_CONFIG_PATH="/home/ubuntu/.ssh/config"
# WEB_DIR="/var/www/html"
# PACKAGES=("apache2" "git" "awscli")
# REPO_URL="git@github.com:omokarogabriel/portfolio.git"

# # === FUNCTIONS ===

# # Install necessary packages
# install_packages() {
#   echo "=== Installing required packages ==="
#   sudo apt-get update -y
#   for pkg in "${PACKAGES[@]}"; do
#     if ! dpkg -s "$pkg" &>/dev/null; then
#       echo "Installing $pkg..."
#       sudo apt-get install -y "$pkg"
#     else
#       echo "$pkg is already installed."
#     fi
#   done
# }

# # Configure SSH Key
# setup_ssh_key() {
#   echo "=== Setting up SSH key ==="
  
#   # Create the .ssh directory with proper permissions
#   mkdir -p "$(dirname "$SSH_KEY_PATH")"
#   chmod 700 "$(dirname "$SSH_KEY_PATH")"
#   chown ubuntu:ubuntu "$(dirname "$SSH_KEY_PATH")"

#   # Fetch key from AWS Secrets Manager
#   aws secretsmanager get-secret-value --secret-id github_ssh_private_key --query SecretString --output text > "$SSH_KEY_PATH"
#   chmod 600 "$SSH_KEY_PATH"
#   chown ubuntu:ubuntu "$SSH_KEY_PATH"

#   # Start the SSH agent and add the key
#   eval "$(ssh-agent -s)"
#   ssh-add "$SSH_KEY_PATH"

#   # Avoid interactive prompt for GitHub host key verification
#   echo "Host github.com
#     StrictHostKeyChecking no" >> "$SSH_CONFIG_PATH"

#   # Add GitHub to known_hosts if not already there
#   ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH" 2>/dev/null
#   chmod 644 "$KNOWN_HOSTS_PATH"
#   chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
# }

# # Deploy repository
# deploy_repository() {
#   echo "=== Deploying GitHub repository ==="
#   sudo rm -rf "${WEB_DIR:?}"/*
#   sudo -u ubuntu git clone "$REPO_URL" "$WEB_DIR"
#   sudo chown -R www-data:www-data "$WEB_DIR"
#   sudo chmod -R 755 "$WEB_DIR"
# }

# # Configure Apache Web Server
# configure_apache() {
#   echo "=== Configuring Apache ==="
#   sudo systemctl start apache2
#   sudo systemctl enable apache2
#   echo "✔️ Apache is running and enabled."
# }

# # Test SSH connection
# test_ssh_connection() {
#   echo "=== Testing SSH connection to GitHub ==="
#   if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
#     echo "✔️ SSH connection successful."
#   else
#     echo "❌ SSH connection failed. Check your SSH key configuration."
#     exit 1
#   fi
# }

# # === MAIN SCRIPT EXECUTION ===
# install_packages
# setup_ssh_key
# test_ssh_connection
# deploy_repository
# configure_apache

# echo "🚀 Deployment complete! Your site should be live."
