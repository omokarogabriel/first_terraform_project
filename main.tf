provider "aws" {
  region = var.region
}

# Fetches the list of all available AZs in the specified region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

   tags = {
    Name = "My_VPC"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

   tags = {
    Name = "My_VPC_IGW"
  }
}

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


resource "aws_route_table_association" "public" {
    count = 2
    subnet_id = aws_subnet.for_publicEC2[count.index].id
    route_table_id = aws_route_table.for_public_access.id
}


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

# resource "aws_iam_role" "ec2_secrets_role" {
#   name               = "EC2SecretsRole"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "ec2_secrets_policy" {
#   name        = "EC2SecretsManagerPolicy"
#   description = "Allows EC2 to get GitHub SSH Key from Secrets Manager"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = ["secretsmanager:GetSecretValue"],
#         Resource = "arn:aws:secretsmanager:us-east-1:401739135392:secret:github_ssh_private_key-*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
#   role       = aws_iam_role.ec2_secrets_role.name
#   policy_arn = aws_iam_policy.ec2_secrets_policy.arn
# }

# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "EC2InstanceProfile"
#   role = aws_iam_role.ec2_secrets_role.name
# }

resource "aws_instance" "public_server" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.for_publicEC2[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id, aws_security_group.ssh_sg.id]
  associate_public_ip_address = true
  key_name = "AwsKey"

  # Reference the instance profile created via AWS CLI
  # iam_instance_profile = "aws_iam_instance_profile.ec2_instance_profile.name" 

  user_data = file("./user_data.sh")

  tags = {
    Name = "My_VPC_Web_Server"
  }

}