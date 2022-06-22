variable "env" {
  description = "Environment Name"
  default = "dev"
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list
}

variable "vpc_cidr" {
  type = string
}
