variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "sg_name" {
  type    = string
  default = "tf-artifactory-sg"
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
  default = "tf-artifactory-ssh-key.pem"
}


variable "user" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  default     = { "Project" = "coffr" }
  description = "Resource tags"
}
