terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge(var.tags, { User = var.user })
  }
}
