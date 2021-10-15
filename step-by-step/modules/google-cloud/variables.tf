variable "aws_vpn_connection" {
  description = "The aws vpn connection object"
  type = object({
    tunnel1_address = string,
    tunnel1_preshared_key = string,
    tunnel1_vgw_inside_address = string,
    tunnel1_cgw_inside_address = string,
    tunnel2_address = string,
    tunnel2_preshared_key = string,
    tunnel2_vgw_inside_address = string,
    tunnel2_cgw_inside_address = string,
  })
}
variable "aws_subnets" {
  description = "The aws subnet cidr blocks"
  type = list
}
