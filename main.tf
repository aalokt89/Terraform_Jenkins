# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Define the VPC
#----------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name        = "${var.app_name}_vpc"
    Environment = var.environment
    Terraform   = "true"
  }
}

# deploy subnets
#----------------------------------------------------
# deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 1)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name        = "${var.app_name}_${each.key}"
    Environment = var.environment
    Terraform   = "true"
  }
}

# deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  map_public_ip_on_launch = var.auto_ipv4

  tags = {
    Name        = "${var.app_name}_${each.key}"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Create Internet Gateway
#----------------------------------------------------
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.app_name}_igw"
    Environment = var.environment
    Terraform   = true
  }
}

#Edit default route table for public subnets
#----------------------------------------------------
resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "${var.app_name}_public_rt"
    Terraform = "true"
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_default_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

# Deploy security groups
#----------------------------------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.jenkins_server_name}_sg"
  description = "Allow ssh and http/https traffic"
  vpc_id      = aws_vpc.vpc.id

  # ssh
  ingress {
    description = "ssh from IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_location]
  }

  ingress {
    description = "jenkins default port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.all_traffic]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all_traffic]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}_${var.jenkins_server_name}_sg"
    Environment = var.environment
    Terraform   = "true"
  }
}

# deploy ec2 instance
#----------------------------------------------------
resource "aws_instance" "jenkins_server" {
  ami                    = var.jenkins_server_ami
  instance_type          = var.jenkins_server_type
  subnet_id              = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_pair
  user_data              = file("${path.module}/${var.user_data_file}")
  iam_instance_profile   = aws_iam_instance_profile.jenkins_s3_instance_profile.name

  tags = {
    Name        = "${var.app_name}_${var.jenkins_server_name}"
    Environment = var.environment
    Terraform   = true
  }
}


# deploy S3 bucket
#----------------------------------------------------
# random alphanum
resource "random_id" "randomize" {
  byte_length = 8
}

resource "aws_s3_bucket" "jenkins_artifacts_s3" {
  bucket        = "${var.app_name}-${var.s3_name}-${random_id.randomize.hex}"
  force_destroy = var.s3_force_destroy

  tags = {
    Name        = "${var.app_name}_${var.s3_name}_s3"
    Environment = var.environment
    Terraform   = "true"
  }
}
# set s3 to private
resource "aws_s3_bucket_public_access_block" "s3_private_access" {
  bucket                  = aws_s3_bucket.jenkins_artifacts_s3.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# create IAM role
#----------------------------------------------------
resource "aws_iam_role" "jenkins_s3_role" {
  name = "jenkins_s3_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# create IAM policy
#----------------------------------------------------
resource "aws_iam_policy" "jenkins_s3_policy" {
  name = var.iam_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = var.iam_actions
        Resource = [
          "${var.iam_resource_type}${aws_s3_bucket.jenkins_artifacts_s3.bucket}",
          "${var.iam_resource_type}${aws_s3_bucket.jenkins_artifacts_s3.bucket}/*"
        ]
      }
    ]

  })
}

# create IAM policy attachment
#----------------------------------------------------
resource "aws_iam_role_policy_attachment" "jenkins_s3_policy_attachment" {
  role       = aws_iam_role.jenkins_s3_role.name
  policy_arn = aws_iam_policy.jenkins_s3_policy.arn
}

# create IAM instance profile
#----------------------------------------------------
resource "aws_iam_instance_profile" "jenkins_s3_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.jenkins_s3_role.name
}
