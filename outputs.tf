output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.public_server.public_ip
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
