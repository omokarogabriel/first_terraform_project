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
# set -euxo pipefail

# # Log all output for debugging (view with: sudo less /var/log/user-data.log)
# # exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# # === VARIABLES ===
# export AWS_REGION="us-east-1"
# export AWS_DEFAULT_REGION="$AWS_REGION"
# SSH_KEY_PATH="/home/ubuntu/.ssh/id_rsa"
# KNOWN_HOSTS_PATH="/home/ubuntu/.ssh/known_hosts"
# SSH_CONFIG_PATH="/home/ubuntu/.ssh/config"
# WEB_DIR="/var/www/html"
# REPO_URL="git@github.com:omokarogabriel/my-port-folio.git"
# SECRET_ID="new_github_ssh_private_key"

# # === INSTALL PACKAGES ===
# sudo apt-get update -y
# sudo apt-get install -y apache2 git awscli

# # === SET UP SSH KEY FOR GITHUB ===
# sudo -u ubuntu mkdir -p "$(dirname "$SSH_KEY_PATH")"
# sudo aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query SecretString --output text --region "$AWS_REGION" > "$SSH_KEY_PATH"
# sudo chown ubuntu:ubuntu "$SSH_KEY_PATH"
# sudo chmod 600 "$SSH_KEY_PATH"

# # === SET UP SSH CONFIG AND KNOWN HOSTS ===
# echo "Host github.com
#     HostName github.com
#     User git
#     IdentityFile $SSH_KEY_PATH
#     StrictHostKeyChecking no" | sudo tee "$SSH_CONFIG_PATH" > /dev/null
# sudo chown ubuntu:ubuntu "$SSH_CONFIG_PATH"
# sudo chmod 600 "$SSH_CONFIG_PATH"

# sudo -u ubuntu ssh-keyscan github.com >> "$KNOWN_HOSTS_PATH"
# sudo chown ubuntu:ubuntu "$KNOWN_HOSTS_PATH"
# sudo chmod 644 "$KNOWN_HOSTS_PATH"

# # === TEST SSH CONNECTION TO GITHUB ===
# SSH_OUTPUT=$(sudo -u ubuntu ssh -T git@github.com 2>&1 || true)
# echo "$SSH_OUTPUT"
# if ! echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
#   echo "❌ SSH connection to GitHub failed. Check your SSH key or repo deploy key settings."
#   exit 1
# fi

# # === DEPLOY THE REPOSITORY ===
# sudo rm -rf "${WEB_DIR:?}"/*
# sudo chown ubuntu:ubuntu "$WEB_DIR"
# sudo -u ubuntu GIT_SSH_COMMAND="ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no -F $SSH_CONFIG_PATH" git clone "$REPO_URL" "$WEB_DIR"
# sudo rm -rf "$WEB_DIR/.git"
# sudo chown -R www-data:www-data "$WEB_DIR"
# sudo chmod -R 755 "$WEB_DIR"

# # === CONFIGURE AND START APACHE ===
# sudo systemctl start apache2
# sudo systemctl enable apache2

# echo "🚀 Deployment complete! Your site should be live."





# #!/bin/bash
# set -euxo pipefail

# #install ansible, awscli, and git
# sudo apt-get update -y
# sudo apt-get install -y ansible awscli git

# #Run the ansible playbook
# # ansible-playbook -i inventory.ini playbook.yml --extra-vars "ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_rsa"


# git clone git@github.com:omokarogabriel/first_ansible_file.git /home/ubuntu/your-ansible-repo
# cp /home/ubuntu/your-ansible-repo/playbook.yml /tmp/ansible/playbook.yml
# cp /home/ubuntu/your-ansible-repo/ansible.host.ini /tmp/ansible.host.ini
# ansible-playbook /tmp/ansible/playbook.yml -i /tmp/ansible.host.ini


# # git clone git@github.com:omokarogabriel/first_ansible_file.git /home/ubuntu/your-ansible-repo
# # ansible-playbook /home/ubuntu/your-ansible-repo/playbook.yml -i /home/ubuntu/your-ansible-repo/ansible.host.ini


# # git clone git@github.com:omokarogabriel/first_ansible_file.git /tmp/ansible
# # ansible-playbook /tmp/ansible/playbook.yml -i /tmp/ansible.host.ini

# # Check if the playbook ran successfully
# if [ $? -eq 0 ]; then
#     echo "Ansible playbook executed successfully."
# else
#     echo "Ansible playbook execution failed."
#     exit 1
# fi
# # Restart Apache to apply any changes made by the playbook




#!/bin/bash
# set -euxo pipefail

# === Pre-checks ===

# Ensure required tools are installed
# for tool in terraform ansible-playbook jq git awscli terraform; do
  # if ! command -v $tool &> /dev/null; then
    # echo "$tool is not installed. Installing..."
    sudo apt-get update -y
    sudo apt-get install -y git awscli apache2
  # fi
# done

# === Verify AWS CLI Configuration ===
# if ! aws sts get-caller-identity &> /dev/null; then
#   echo "AWS CLI is not configured. Please run: aws configure"
#   exit 1
# fi

# # === Run Terraform ===
# terraform init
# terraform apply -auto-approve

# === Extract EC2 public IPs ===
# terraform output -json instance_public_ips | jq -r '.[]' > /tmp/instance_ips.txt

# === Generate Ansible inventory ===
# echo "[ec2_instances]" > /tmp/ansible.host.ini
# cat /tmp/instance_ips.txt >> /tmp/ansible.host.ini

# === Clone Ansible repo ===
# rm -rf /tmp/ansible-repo
# git clone https://github.com/omokarogabriel/portfolio.git /home/ubuntu

sudo mv /home/ubuntu/portfolio/* /var/www/html/

sudo -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/ 

# === Check SSH key ===
# PRIVATE_KEY="/home/omokaro/AwsKey"
# if [ ! -f "$PRIVATE_KEY" ]; then
#   echo "Private key file not found at $PRIVATE_KEY"
#   exit 1
# fi

# === Run Ansible playbook ===
# ansible-playbook /tmp/ansible-repo/playbook.yml \
#   -i /tmp/ansible.host.ini \
#   --user=ubuntu \
#   --private-key="$PRIVATE_KEY"

# === Display Web Page URL ===
# WEB_IP=$(head -n1 /tmp/instance_ips.txt)
# echo "Web page should be available at: http://$WEB_IP/"

# === Optional: Auto-open in browser ===
# xdg-open "http://$WEB_IP/"  # For Linux
# open "http://$WEB_IP/"      # For macOS
