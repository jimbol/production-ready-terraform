variable "vpc_id" {
  description = "ID of our VPC"
  type = string
}

variable "subnet_ids" {
  description = "These are the subnets that should be accessible via vpn"
  type = list
}

variable "vpc_cidr" {
  description = "The cidr block that can be accessed via vpn"
  type = string
}
