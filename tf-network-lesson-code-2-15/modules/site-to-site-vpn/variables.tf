variable "vpc_id" {
  description = "ID of our VPC"
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "google_vpc_cidr" {
  type = string
}
variable "google_vpn_address" {
  description = "The address of the google vpn"
  type = string
}
variable "aws_private_route_table_id" {
  type = string
}
variable "aws_public_route_table_id" {
  type = string
}
