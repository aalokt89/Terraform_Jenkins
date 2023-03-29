terraform {
  cloud {
    organization = "aalok-trivedi"
    workspaces {
      name = "jenkins_server"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
