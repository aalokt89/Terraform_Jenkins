variable "aws_region" {
  type    = string
  default = "us-east-1"
}
# naming vars
#---------------------------------------
variable "app_name" {
  type        = string
  description = "app name prefix for naming"
  default     = "brainiac"
}

# vpc vars
#----------------------------------------
variable "vpc_cidr" {
  type        = string
  description = "VPC cidr block"
  default     = "10.0.0.0/16"
}

# private subnet vars
#----------------------------------------
variable "private_subnets" {
  default = {
    "private_subnet_1" = 0
    "private_subnet_2" = 1
  }
}

# public subnet vars
#----------------------------------------
variable "public_subnets" {
  default = {
    "public_subnet_1" = 0
    "public_subnet_2" = 1
  }
}

# ec2 vars
#----------------------------------------
variable "jenkins_server_name" {
  type    = string
  default = "jenkins_server"
}
variable "jenkins_server_ami" {
  type        = string
  description = "Instance AMI: Amazon Linux 2"
  default     = "ami-04581fbf744a7d11f"
}
variable "jenkins_server_type" {
  type    = string
  default = "t2.micro"
}

# security group vars
#----------------------------------------
variable "ssh_location" {
  type        = string
  description = "My IP address"
  default     = "0.0.0.0/0"
}

# S3 vars
#----------------------------------------
variable "s3_name" {
  type    = string
  default = "jenkins_artifacts"
}

# VPC vars
#----------------------------------------
