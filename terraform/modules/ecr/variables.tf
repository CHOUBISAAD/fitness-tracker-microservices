variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "repositories" {
  type        = list(string)
  description = "List of ECR repository names"
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "tags" {
  type = map(string)
}
