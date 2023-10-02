terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
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
  name        = var.artifactory_security_group_name
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
    from_port   = 8082
    to_port     = 8082
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

resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.tls_private_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.tls_private_key.private_key_openssh
  filename        = var.ssh_private_file_name
  file_permission = 0400
}

resource "aws_instance" "artifactory_instance" {
  ami                    = data.aws_ami.centos_stream_8.id
  instance_type          = var.artifactory_instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
  key_name               = aws_key_pair.key_pair.key_name
  tags                   = merge(var.tags, { Name = var.artifactory_server_name })
  root_block_device {
    volume_size = 100
  }
}
