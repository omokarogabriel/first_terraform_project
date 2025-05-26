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

## **This project uses aws secret manager**
- ```bash
aws secretsmanager get-secret-value \
    --secret-id new_github_ssh_private_key \
    --query SecretString \
    --region us-east-1 \
    --output text


## **I created a Role for the ec2 to access the resource (aws secret manager)**
- ```bash
resource "aws_iam_role" "ec2_secrets_role" {
  name = "MyEC2SecretsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

## **I also created a policy that the ec2 must do**
- ```bash
resource "aws_iam_policy" "ec2_secrets_policy" {
  name        = "EC2SecretsManagerPolicy"
  description = "Allows EC2 to get GitHub SSH Key from Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      # Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:new_github_ssh_private_key"
    "Resource": "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:new_github_ssh_private_key-*"

    }]
  })
}

## **I attached the role and the policy together**
- ```bash
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_role.name
  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

## **I created an instance profile, beacuse the ec2 cannot access the Role alone**
- ```bash
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "MyEC2InstanceProfile"
  role = aws_iam_role.ec2_secrets_role.name
}

## **I added the instance profile to the ec2 instance, so the ec2 will have access to the sercet**
## iam_instance_profile       = aws_iam_instance_profile.ec2_instance_profile.name

## 🔧 **Setup Instructions**
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/terraform-aws-infra.git
   cd terraform-aws-infra
