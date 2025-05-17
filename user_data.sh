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
setup_ssh_key() {
  echo "Setting up SSH key..."
  mkdir -p "$(dirname "$SSH_KEY_PATH")"
  chmod 700 "$(dirname "$SSH_KEY_PATH")"
  chown ubuntu:ubuntu "$(dirname "$SSH_KEY_PATH")"

  aws secretsmanager get-secret-value --secret-id github_ssh_private_key --query SecretString --output text > "$SSH_KEY_PATH"
  chmod 600 "$SSH_KEY_PATH"
  chown ubuntu:ubuntu "$SSH_KEY_PATH"

  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY_PATH"

  ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH"
  chmod 644 "$KNOWN_HOSTS_PATH"
  chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
}

# Function to deploy GitHub repository
deploy_repository() {
  echo "Deploying GitHub repository..."
  rm -rf "${WEB_DIR:?}"/*
  git clone git@github.com:omokarogabriel/my-port-folio.git "$WEB_DIR"
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
