variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type = string
}
variable "subnet_ids" {
  description = "Subnet ids that should be accessibly via VPN"
  type = list
}
