variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}
variable "google_vpn_address" {
  description = "The VPN IP address in google"
  type = string
}
variable "public_route_table_id" {
  description = "The id of the public route table"
  type = string
}
variable "private_route_table_id" {
  description = "The id of the private route table"
  type = string
}
