# Client VPN
resource "aws_acm_certificate" "app_cert" {
  certificate_body      = file("~/tfclass/server.crt")
  private_key           = file("~/tfclass/server.key")
  certificate_chain     = file("~/tfclass/ca.crt")
}

resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  description            = "terraform-clientvpn-example"
  server_certificate_arn = aws_acm_certificate.app_cert.arn
  client_cidr_block      = "172.16.0.0/22"
  split_tunnel           = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.app_cert.arn
  }

  connection_log_options {
    enabled = false
  }
}

# Site to site VPN Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "vpn-gateway"
  }
}

# Requests automatic route propagation between a VPN gateway and a route table.
resource "aws_vpn_gateway_route_propagation" "main" {
  count = length(var.aws_route_table_ids)

  route_table_id = var.aws_route_table_ids[count.index]
  vpn_gateway_id = aws_vpn_gateway.main.id
}

# Connected to VPN gateways via VPN connections, and allow you to
# establish tunnels between your network and the VPC.
resource "aws_customer_gateway" "google" {
  bgp_asn    = 65000
  ip_address = var.google_compute_address
  type       = "ipsec.1"

  tags = {
    Name = "google-vpn-customer-gateway"
  }
}

resource "aws_vpn_connection" "google" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.google.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "google-vpn-connection"
  }
}
