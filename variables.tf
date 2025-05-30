variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0fc5d935ebf8bc3bc"
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 2
}
