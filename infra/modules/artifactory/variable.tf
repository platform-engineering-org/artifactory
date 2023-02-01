variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region to launch servers."
}

variable "artifactory_security_group_name" {
  type    = string
  default = "tf-artifactory-security-group"
}

variable "secretsmanager_policy" {
  type        = string
  default     = "tf-secretsmanager-policy"
  description = "Consume Secrets from Secrets Manager"
}

variable "artifactory_iam_role_name" {
  type        = string
  default     = "tf-artifactory-iam-role-name"
  description = "Artifactory instance IAM Role name"
}

variable "artifactory_iam_instance_profile" {
  type        = string
  default     = "tf-artifactory-iam-instance-profile"
  description = "Artifactory IAM instance profile"
}

variable "ssh_key_name" {
  type    = string
  default = "tf-artifactory-ssh-key"
}

variable "ssh_private_file_name" {
  type    = string
  default = "/workspace/tf-artifactory-ssh-key.pem"
}


variable "artifactory_instance_type" {
  type        = string
  default     = "m5.large"
  description = "Artifactory EC2 instance type"
}

variable "artifactory_server_name" {
  type        = string
  default     = "artifactory"
  description = "Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team"
}

variable "user" {
  type    = string
  default = ""
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "tags" {
  type = map(string)
  default = {
    "Project" = "platform-engineering"
  }
  description = "Resource tags"
}
