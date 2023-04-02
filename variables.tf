variable "environment" {
  type    = string
  default = "Dev"
}

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

variable "enable_dns_hostnames" {
  type        = bool
  description = "enable dns hostnames"
  default     = true
}

# common cidrs
#----------------------------------------
variable "all_traffic" {
  type        = string
  description = "all all traffic"
  default     = "0.0.0.0/0"
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
variable "auto_ipv4" {
  type        = bool
  description = "enable auto-assign ipv4"
  default     = true
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

variable "key_pair" {
  type        = string
  description = "ec2 key pair"
  default     = "webServer_key"
}

variable "user_data_file" {
  type        = string
  description = "user data file path"
  default     = "install_jenkins.sh"
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
  default = "jenkins-artifacts"
}
variable "s3_force_destroy" {
  type    = bool
  default = true
}

# S3 private
variable "block_public_acls" {
  type    = bool
  default = true
}
variable "block_public_policy" {
  type    = bool
  default = true
}
variable "ignore_public_acls" {
  type    = bool
  default = true
}
variable "restrict_public_buckets" {
  type    = bool
  default = true
}

# IAM vars
#----------------------------------------
# role name
variable "iam_role_name" {
  type        = string
  description = "IAM role name"
  default     = "jenikins_s3_role"
}

# policy name
variable "iam_policy_name" {
  type        = string
  description = "IAM policy name"
  default     = "jenikins_s3_policy"
}

# policy resource actions
variable "iam_actions" {
  type        = list(string)
  description = "actions allowed by Jenkins server"
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]
}

# resource type/prefix
variable "iam_resource_type" {
  type        = string
  description = "IAM policy resource type"
  default     = "arn:aws:s3:::"
}

# instance profile name
variable "iam_instance_profile_name" {
  type        = string
  description = "instance profile name"
  default     = "jenkins_s3_instance_profile"
}
