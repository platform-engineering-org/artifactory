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

data "aws_ami" "centos_stream_8" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["CentOS Stream 8 *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "security_group" {
  name        = var.sg_name
  description = "Artifactory inbound and outbound traffic"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    sid = "1"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "secretmanager_iam_policy_document" {
  statement {
    sid = "1"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "iam_role" {
  name               = var.artifactory_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
  inline_policy {
    name   = var.secretsmanager_policy
    policy = data.aws_iam_policy_document.secretmanager_iam_policy_document.json
  }
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = var.artifactory_iam_instance_profile
  role = aws_iam_role.iam_role.name
}
