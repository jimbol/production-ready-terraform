variable "env" {
  description = "Environment Name"
  default = "dev"
  type = string
}
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
}
variable "public_subnet_cidr" {
  description = "public subnet CIDR block"
  type = string
}
variable "private_subnet_cidr" {
  description = "private subnet CIDR block"
  type = string
}
