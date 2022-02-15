variable "env" {
  description = "Environment name"
  default = "dev"
  type = string
}

variable "vpc_cidr" {
  description = "Range of IP addresses available in our VPC"
  type = string
}

