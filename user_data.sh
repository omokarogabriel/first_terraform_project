# #!/bin/bash
# set -euo pipefail

# export AWS_REGION="us-east-1"
# export AWS_DEFAULT_REGION="$AWS_REGION"
# SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
# KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
# SSH_CONFIG_PATH="/home/ubuntu/.ssh/config"
# WEB_DIR="/var/www/html"
# PACKAGES=("apache2" "git" "awscli")
# REPO_URL="git@github.com:omokarogabriel/my-port-folio.git"

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

# setup_ssh_key() {
#   echo "=== Setting up SSH key ==="
#   mkdir -p "$(dirname "$SSH_KEY_PATH")"
#   chmod 700 "$(dirname "$SSH_KEY_PATH")"
#   chown -R ubuntu:ubuntu "$(dirname "$SSH_KEY_PATH")"

#   aws secretsmanager get-secret-value --secret-id new_github_ssh_private_key --query SecretString --output text --region "$AWS_DEFAULT_REGION" > "$SSH_KEY_PATH"
#   chmod 600 "$SSH_KEY_PATH"
#   chown ubuntu:ubuntu "$SSH_KEY_PATH"

#   eval "$(ssh-agent -s)"
#   ssh-add "$SSH_KEY_PATH"

#   echo "Host github.com
#     HostName github.com
#     User git
#     IdentityFile $SSH_KEY_PATH
#     StrictHostKeyChecking no" > "$SSH_CONFIG_PATH"

#   chmod 600 "$SSH_CONFIG_PATH"
#   chown ubuntu:ubuntu "$SSH_CONFIG_PATH"

#   ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH" 2>/dev/null
#   chmod 644 "$KNOWN_HOSTS_PATH"
#   chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
# }

# test_ssh_connection() {
#   echo "=== Testing SSH connection to GitHub ==="
#   SSH_OUTPUT=$(ssh -T git@github.com 2>&1 || true)
#   echo "$SSH_OUTPUT"
#   if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
#     echo "✔️ SSH connection successful."
#   else
#     echo "❌ SSH connection failed. Check your SSH key configuration."
#     exit 1
#   fi
# }

# deploy_repository() {
#   echo "=== Deploying GitHub repository ==="
#   sudo rm -rf "${WEB_DIR:?}"/*
#   sudo chown -R ubuntu:ubuntu "$WEB_DIR"
#   GIT_SSH_COMMAND="ssh -i $SSH_KEY_PATH -o UserKnownHostsFile=$KNOWN_HOSTS_PATH -F $SSH_CONFIG_PATH" git clone "$REPO_URL" "$WEB_DIR"
#   sudo rm -rf "$WEB_DIR/.git"
#   sudo chown -R www-data:www-data "$WEB_DIR"
#   sudo chmod -R 755 "$WEB_DIR"
# }

# configure_apache() {
#   echo "=== Configuring Apache ==="
#   sudo systemctl start apache2
#   sudo systemctl enable apache2
#   echo "✔️ Apache is running and enabled."
# }

# install_packages
# setup_ssh_key
# test_ssh_connection
# deploy_repository
# configure_apache

# echo "🚀 Deployment complete! Your site should be live."












#!/bin/bash
set -euxo pipefail

# Log all output for debugging (view with: sudo less /var/log/user-data.log)
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# === VARIABLES ===
export AWS_REGION="us-east-1"
export AWS_DEFAULT_REGION="$AWS_REGION"
SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
SSH_CONFIG_PATH="/home/ubuntu/.ssh/config"
WEB_DIR="/var/www/html"
REPO_URL="git@github.com:omokarogabriel/my-port-folio.git"
SECRET_ID="new_github_ssh_private_key"

# === INSTALL PACKAGES ===
sudo apt-get update -y
sudo apt-get install -y apache2 git awscli

# === SET UP SSH KEY FOR GITHUB ===
sudo -u ubuntu mkdir -p "$(dirname "$SSH_KEY_PATH")"
sudo aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query SecretString --output text --region "$AWS_REGION" > "$SSH_KEY_PATH"
sudo chown ubuntu:ubuntu "$SSH_KEY_PATH"
sudo chmod 600 "$SSH_KEY_PATH"

# === SET UP SSH CONFIG AND KNOWN HOSTS ===
echo "Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY_PATH
    StrictHostKeyChecking no" | sudo tee "$SSH_CONFIG_PATH" > /dev/null
sudo chown ubuntu:ubuntu "$SSH_CONFIG_PATH"
sudo chmod 600 "$SSH_CONFIG_PATH"

sudo -u ubuntu ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH"
sudo chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
sudo chmod 644 "$KNOWN_HOSTS_PATH"

# === TEST SSH CONNECTION TO GITHUB ===
SSH_OUTPUT=$(sudo -u ubuntu ssh -T git@github.com 2>&1 || true)
echo "$SSH_OUTPUT"
if ! echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
  echo "❌ SSH connection to GitHub failed. Check your SSH key or repo deploy key settings."
  exit 1
fi

# === DEPLOY THE REPOSITORY ===
sudo rm -rf "${WEB_DIR:?}"/*
sudo chown ubuntu:ubuntu "$WEB_DIR"
sudo -u ubuntu GIT_SSH_COMMAND="ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no -F $SSH_CONFIG_PATH" git clone "$REPO_URL" "$WEB_DIR"
sudo rm -rf "$WEB_DIR/.git"
sudo chown -R www-data:www-data "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

# === CONFIGURE AND START APACHE ===
sudo systemctl start apache2
sudo systemctl enable apache2

echo "🚀 Deployment complete! Your site should be live."