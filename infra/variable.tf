variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "sg_name" {
  type    = string
  default = "tf-artifactory-sg"
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
