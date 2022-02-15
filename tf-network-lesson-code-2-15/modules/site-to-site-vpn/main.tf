resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id
}

resource "aws_customer_gateway" "aws_to_google_gateway" {
  bgp_asn = 65000

  ip_address = var.google_vpn_address
  type = "ipsec.1"

  tags = {
    name = "aws to google gateway"
  }
}

resource "aws_vpn_connection" "aws_to_google_vpn_connection" {
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.aws_to_google_gateway.id

  type = "ipsec.1"
  static_routes_only = false

  remote_ipv4_network_cidr = var.vpc_cidr # 10.0.0.0/16
  local_ipv4_network_cidr = var.google_vpc_cidr # 11.0.0.0/24
}

resource "aws_vpn_gateway_route_propagation" "public_route_table_propagation" {
  route_table_id = var.aws_public_route_table_id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_vpn_gateway_route_propagation" "private_route_table_propagation" {
  route_table_id = var.aws_private_route_table_id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}
