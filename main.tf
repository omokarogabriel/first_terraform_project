#Region
provider "aws" {
  region = var.region
}

# Fetches the list of all available AZs in the specified region
data "aws_availability_zones" "available" {}

#Fetches the account-id
data "aws_caller_identity" "current" {}


#VPC CREATION
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

   tags = {
    Name = "My_VPC"
  }
}


#INTERNET GATEWAY CREATION

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

   tags = {
    Name = "My_VPC_IGW"
  }
}


#SUBNET FOR PUBLIC
resource "aws_subnet" "for_publicEC2" {
  count = 2
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "My_VPC_Subnets"
  }
}


#ROUTE TABLE FOR INTERNET ACCESS
resource "aws_route_table" "for_public_access" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "My_VPC_RT"
  }
}


#ASSOCIATING THE ROUTE TABLE WITH THE EC2 INSTANCE
resource "aws_route_table_association" "public" {
    count = 2
    subnet_id = aws_subnet.for_publicEC2[count.index].id
    route_table_id = aws_route_table.for_public_access.id
}



#SECURITY GROUP FOR TRAFFIC HTTP AND HTTPS
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and HTTPS"
  vpc_id = aws_vpc.my_vpc.id
  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My_VPC_SG"
  }
}


#SECURITY GROUP FOR SSH ACCESS

resource "aws_security_group" "ssh_sg" {
  name        = "ssh-sg"
  description = "Allow SSH access"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "My_VPC_SSH"
  }
}

# security rule accepting traffic from the web security group to the ssh security group
# resource "aws_security_group_rule" "allow_web_to_ssh" {
#   type              = "ingress"
#   from_port        = 22
#   to_port          = 22
#   protocol         = "tcp"
#   security_group_id = aws_security_group.ssh_sg.id
#   source_security_group_id = aws_security_group.web_sg.id

#   description = "Allow SSH access from web security group"
# }

#allow ssh to ec2
resource "aws_security_group_rule" "allow_ssh_to_ec2" {
  type              = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  security_group_id = aws_security_group.web_sg.id
  source_security_group_id = aws_security_group.ssh_sg.id
}


# #ROLE CREATION FOR  EC2 RESOURCE ACCESS
# resource "aws_iam_role" "ec2_secrets_role" {
#   name = "EC2SecretsRoles"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       },
#       Action = "sts:AssumeRole"
#     }]
#   })

#   tags = {
#     Name = "EC2SecretsRole"
#   }
# }

# resource "aws_iam_policy" "ec2_secrets_policy" {
#   name        = "EC2SecretsManagerPolicy"
#   description = "Allows EC2 to get GitHub SSH Key from Secrets Manager"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Action = [
#         "secretsmanager:GetSecretValue",
#         "secretsmanager:DescribeSecret"
#       ],
#       Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:new_github_ssh_private_key*"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
#   role       = aws_iam_role.ec2_secrets_role.name
#   policy_arn = aws_iam_policy.ec2_secrets_policy.arn
# }

# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "EC2InstanceProfiles"
#   role = aws_iam_role.ec2_secrets_role.name
# }



# #EC2 INSTANCE
# resource "aws_instance" "public_server" {
#   ami = var.ami
#   instance_type = var.instance_type
#   subnet_id = aws_subnet.for_publicEC2[0].id
#   vpc_security_group_ids = [aws_security_group.web_sg.id, aws_security_group.ssh_sg.id]
#   associate_public_ip_address = true
#   key_name = "AwsKey"

#   # Reference the instance profile created via AWS CLI
#   # iam_instance_profile = "aws_iam_instance_profile.ec2_instance_profile.name" 
#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

#   user_data = file("./user_data.sh")

#   tags = {
#     Name = "My_VPC_Web_Server"
#   }

# }

# #SECRETS MANAGER FOR SSH KEY  

# resource "aws_secretsmanager_secret" "my_private_key" {
#   name = "new_github_ssh_private_key"
#   description = "My private GitHub SSH key"
# }

# resource "aws_secretsmanager_secret_version" "my_private_key_version" {
#   secret_id     = aws_secretsmanager_secret.my_private_key.id
#   secret_string = file("/home/omokaro/id_ssh") # Path to your private key file
# }



# Reference the secret by name or ARN
data "aws_secretsmanager_secret" "github_ssh_key" {
  name = "new_github_ssh_private_key"
}

data "aws_secretsmanager_secret_version" "github_ssh_key" {
  secret_id = data.aws_secretsmanager_secret.github_ssh_key.id
}








# #ROLE CREATION FOR  EC2 RESOURCE ACCESS
resource "aws_iam_role" "ec2_secrets_role" {
  name = "ForEC2SecretsRole"

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

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_role.name
  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "MyEC2InstanceProfile"
  role = aws_iam_role.ec2_secrets_role.name
}



resource "aws_instance" "public_server" {
  count                     = var.instance_count
  ami                         = var.ami
  instance_type              = var.instance_type
  subnet_id                  = aws_subnet.for_publicEC2[0].id
  vpc_security_group_ids     = [aws_security_group.web_sg.id, aws_security_group.ssh_sg.id]
  associate_public_ip_address = true
  key_name                    = "AwsKey"
  iam_instance_profile       = aws_iam_instance_profile.ec2_instance_profile.name
  user_data                  = file("./user_data.sh")

  tags = {
    Name = "My_VPC_Web_Server"
  }
}
