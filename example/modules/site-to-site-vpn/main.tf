resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id
}


resource "aws_customer_gateway" "customer_gateway_1" {
  bgp_asn    = 65000
  ip_address = var.google_vpn_interfaces[0].ip_address
  type       = "ipsec.1"
}
resource "aws_customer_gateway" "customer_gateway_2" {
  bgp_asn    = 65000
  ip_address = var.google_vpn_interfaces[1].ip_address
  type       = "ipsec.1"
}


resource "aws_vpn_connection" "vpn_gateway_1" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_1.id
  type                = "ipsec.1"
}
resource "aws_vpn_connection" "vpn_gateway_2" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_2.id
  type                = "ipsec.1"
}


resource "aws_vpn_gateway_route_propagation" "public_route_table_propagation" {
  route_table_id = var.aws_public_route_table_id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_vpn_gateway_route_propagation" "private_route_table_propagation" {
  route_table_id = var.aws_private_route_table_id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}
