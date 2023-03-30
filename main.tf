# random alphanum
resource "random_string" "randomize" {
  length = 8
}

# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Define the VPC
#----------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.app_name}_vpc"
    Environment = "dev"
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
    Name      = "${var.app_name}_${each.key}"
    Terraform = "true"
  }
}

# deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.app_name}_${each.key}"
    Terraform = "true"
  }
}

# Create Internet Gateway
#----------------------------------------------------
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name      = "${var.app_name}_igw"
    Terraform = true
  }
}


#Edit default route table for public subnets
#----------------------------------------------------
resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
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

# deploy ec2 instance
#----------------------------------------------------
resource "aws_instance" "jenkins_server" {
  ami                    = var.jenkins_server_ami
  instance_type          = var.jenkins_server_type
  subnet_id              = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "webServer_key"
  user_data              = file("${path.module}/user_data_jenkins.sh")

  tags = {
    Name      = "${var.app_name}_${var.jenkins_server_name}"
    Terraform = true
  }
}

# # deploy security groups
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.jenkins_server_name}_sg"
    Terraform = "true"
  }
}

# deply S3 bucket
#----------------------------------------------------
