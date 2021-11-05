variable "vpc_cidr" {
  description = "The CIDR block for the entire VPC"
  type = string
}

variable "public_subnet" {
  description = "The CIDR block the public subnet"
  type = string
}

variable "private_subnet" {
  description = "The CIDR block the private subnet"
  type = string
}

