
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet" {
  description = "The CIDR block for the private subnet"
  type        = string
}
