output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.public_server
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = aws_subnet.for_publicEC2[*].id
}

output "web_security_group_id" {
  description = "Security Group ID for Web Traffic"
  value       = aws_security_group.web_sg.id
}

output "ssh_security_group_id" {
  description = "Security Group ID for SSH Access"
  value       = aws_security_group.ssh_sg.id
}

output "route_table_id" {
  description = "Route Table ID for public subnets"
  value       = aws_route_table.for_public_access.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID for VPC"
  value       = aws_internet_gateway.my_vpc_igw.id
}

output "account_id" {
  description = "The AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "ssh_private_key" {
  value     = data.aws_secretsmanager_secret_version.github_ssh_key.secret_string
  sensitive = true
}

output "ssh_private_key_arn" {
  description = "ARN of the SSH private key secret"
  value       = data.aws_secretsmanager_secret.github_ssh_key.arn
}


