# Terraform Project: AWS Infrastructure Deployment

This project automates the provisioning of AWS cloud infrastructure using Terraform. It includes VPC creation, subnets, security groups, EC2 instances.
With deploying a static website using BASH SCRIPT.

## 📌 **Project Structure**

├── main.tf # Main configuration for infrastructure
├── variables.tf # Input variables definition
├── outputs.tf # Outputs from Terraform execution
├── provider.tf # AWS provider configuration
├── user_data.sh # To install packages in the ec2 instance
└── README.md # Project documentation

## 🚀 **Features**
- VPC with public and private subnets
- Internet Gateway configuration
- Security groups for public and access
- EC2 instances with SSH access

## ✅ **Prerequisites**
- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create resources

## 🔧 **Setup Instructions**
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/terraform-aws-infra.git
   cd terraform-aws-infra
