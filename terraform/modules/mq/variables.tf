variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_security_group_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "deployment_mode" {
  type    = string
  default = "SINGLE_INSTANCE"
}

variable "tags" {
  type = map(string)
}
