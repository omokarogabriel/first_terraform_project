

#!/bin/bash
set -euo pipefail

# === VARIABLES ===
export AWS_REGION="us-east-1"   # Change to your correct region
export AWS_DEFAULT_REGION="$AWS_REGION"
SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
SSH_CONFIG_PATH="/home/ubuntu/.ssh/config"
WEB_DIR="/var/www/html"
PACKAGES=("apache2" "git" "awscli")
REPO_URL="git@github.com:omokarogabriel/my-port-folio.git"

# === FUNCTIONS ===

# Install necessary packages
install_packages() {
  echo "=== Installing required packages ==="
  sudo apt-get update -y
  for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      echo "Installing $pkg..."
      sudo apt-get install -y "$pkg"
    else
      echo "$pkg is already installed."
    fi
  done
}

# Configure SSH Key
setup_ssh_key() {
  echo "=== Setting up SSH key ==="
  
  # Create the .ssh directory with proper permissions
  mkdir -p "$(dirname "$SSH_KEY_PATH")"
  chmod 700 "$(dirname "$SSH_KEY_PATH")"
  chown ubuntu:ubuntu "$(dirname "$SSH_KEY_PATH")"

  # Fetch key from AWS Secrets Manager
  aws secretsmanager get-secret-value --secret-id new_github_ssh_private_key --query SecretString --output text --region $AWS_DEFAULT_REGION > "$SSH_KEY_PATH"
  chmod 600 "$SSH_KEY_PATH"
  chown ubuntu:ubuntu "$SSH_KEY_PATH"

  # Start the SSH agent and add the key
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY_PATH"

  # Avoid interactive prompt for GitHub host key verification
  echo "Host github.com
    StrictHostKeyChecking no" >> "$SSH_CONFIG_PATH"

  # Add GitHub to known_hosts if not already there
  ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH" 2>/dev/null
  chmod 644 "$KNOWN_HOSTS_PATH"
  chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
}

# Deploy repository
deploy_repository() {
  echo "=== Deploying GitHub repository ==="
  sudo rm -rf "${WEB_DIR:?}"/*
#   sudo -u ubuntu git clone "$REPO_URL" "$WEB_DIR"
  git clone "$REPO_URL" "$WEB_DIR"
  sudo chown -R www-data:www-data "$WEB_DIR"
  sudo chmod -R 755 "$WEB_DIR"
}

# Configure Apache Web Server
configure_apache() {
  echo "=== Configuring Apache ==="
  sudo systemctl start apache2
  sudo systemctl enable apache2
  echo "✔️ Apache is running and enabled."
}

# Test SSH connection
test_ssh_connection() {
  echo "=== Testing SSH connection to GitHub ==="
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✔️ SSH connection successful."
  else
    echo "❌ SSH connection failed. Check your SSH key configuration."
    exit 1
  fi
}

# === MAIN SCRIPT EXECUTION ===
install_packages
setup_ssh_key
test_ssh_connection
deploy_repository
configure_apache

echo "🚀 Deployment complete! Your site should be live."