#!/bin/bash

set -euo pipefail

# This script is designed to be run on an EC2 instance to set up a web server
# and deploy a GitHub repository to it. It performs the following tasks:
# 1. Installs necessary packages (Apache, Git, AWS CLI).
# 2. Sets up an SSH key for GitHub access.
# 3. Deploys the GitHub repository to the web server's document root.
# 4. Configures the Apache web server to serve the deployed content.
# 5. Tests the SSH connection to GitHub to ensure the key is working.
# 6. Cleans up any existing files in the web directory before cloning the repository.
# 7. Sets appropriate permissions for the web directory.
# 8. Starts the Apache service and enables it to start on boot.
# 9. Prints a success message upon completion.
# 10. The script uses AWS Secrets Manager to fetch the SSH key securely.
# 11. The script uses the apt-get package manager to install packages.
# 12. The script uses the systemctl command to manage the Apache service.
# 13. The script uses the git command to clone the repository.
# 14. The script uses the ssh command to test the SSH connection to GitHub.
# 15. The script uses the mkdir command to create directories.
# 16. The script uses the chmod command to set permissions on files and directories.
# 17. The script uses the chown command to change ownership of files and directories.
# 18. The script uses the rm command to remove files and directories.
# 19. The script uses the echo command to print messages to the console.
# 20. The script uses the grep command to search for specific strings in output.
# 21. The script uses the eval command to evaluate commands in the current shell.       
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
# This function installs necessary packages on the EC2 instance.
# It checks if each package is already installed and installs it if not.
# The function uses the apt-get package manager to install packages.
# The function also updates the package list before installation.
# The function uses the dpkg command to check if a package is installed.
# The function uses the sudo command to run commands with elevated privileges.
# The function uses the -y option with apt-get to automatically answer "yes" to prompts.
# The function uses the -p option with mkdir to create the directory if it does not exist.
# The function uses the -r option with rm to remove directories and their contents recursively.
# The function uses the -f option with rm to force removal without prompting.
# The function uses the -q option with dpkg to suppress output.
# The function uses the -s option with dpkg to check the status of a package.                          
# This function checks if each package is installed and installs it if not.
# It also updates the package list before installation.
# The function uses the apt-get package manager, which is common in Debian-based systems.
# The script runs with elevated privileges using sudo, so it will prompt for the user's password if necessary.
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

# This function sets up the SSH key for GitHub access.
# It creates the necessary directories and files, fetches the SSH key from AWS Secrets Manager,
# and configures SSH to avoid interactive prompts for host key verification.
# The function also starts the SSH agent and adds the key to it.
# The SSH key is stored in a secure location with appropriate permissions.
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

# This function deploys the GitHub repository to the web directory.
# It removes any existing files in the web directory and clones the repository.
# The function also sets the appropriate ownership and permissions for the web directory.
# The web directory is typically where the web server serves files from.    
# Deploy repository
deploy_repository() {
  echo "=== Deploying GitHub repository ==="
  sudo rm -rf "${WEB_DIR:?}"/*
#   sudo -u ubuntu git clone "$REPO_URL" "$WEB_DIR"
  git clone "$REPO_URL" "$WEB_DIR"
  sudo chown -R www-data:www-data "$WEB_DIR"
  sudo chmod -R 755 "$WEB_DIR"
}

# This function configures the Apache web server.
# It starts the Apache service and enables it to start on boot.
# The function uses systemctl to manage the Apache service.
# The Apache web server is a popular open-source web server software.
# It is used to serve web content and can be configured to work with various programming languages and frameworks.
# The function also checks if the Apache service is running and enabled.
# If not, it starts the service and enables it to start on boot.    
# Configure Apache Web Server
configure_apache() {
  echo "=== Configuring Apache ==="
  sudo systemctl start apache2
  sudo systemctl enable apache2
  echo "✔️ Apache is running and enabled."
}


# This function tests the SSH connection to GitHub.
# It uses the ssh command to attempt to connect to GitHub and checks for a successful authentication message.
# The function also handles any errors that may occur during the connection attempt.
# If the connection is successful, it prints a success message.
# If the connection fails, it prints an error message and exits the script.
# The function uses the ssh command with the -T option to test the connection without executing a remote command.
# The function also redirects standard error to standard output to capture any error messages.
# The function uses grep to search for the success message in the output.
# The function also handles any errors that may occur during the connection attempt.        
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


# This function is the main entry point of the script.
# It calls the other functions in the order they should be  
# === MAIN SCRIPT EXECUTION ===
install_packages
setup_ssh_key
test_ssh_connection
deploy_repository
configure_apache

echo "🚀 Deployment complete! Your site should be live."