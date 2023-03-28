variable "aws_region" {
  type    = string
  default = "us-east-1"
}
# naming vars
#---------------------------------------
variable "app_prefix" {
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
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}

# public subnet vars
#----------------------------------------
variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
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
  description = "Instance AMI"
  default     = "ami-00c39f71452c08778"
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
  default     = "173.167.193.106/32"
}

# S3 vars
#----------------------------------------
variable "s3_name" {
  type    = string
  default = "jenkins_artifacts"
}

# VPC vars
#----------------------------------------
