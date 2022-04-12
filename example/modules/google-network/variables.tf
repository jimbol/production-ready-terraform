variable "cidr_block" {
  description = "Google cloud cidr block"
  type = string
}

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
  description = "The aws subnets that we want to be able to connect to"
  type = list
}
