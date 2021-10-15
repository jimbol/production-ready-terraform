resource "aws_acm_certificate" "app_cert" {
  certificate_body      = file("~/tfclass/server.crt")
  private_key           = file("~/tfclass/server.key")
  certificate_chain     = file("~/tfclass/ca.crt")
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = "Client VPN endpoint"

  # within the network, clients will be assigned ip addresses from this cidr block
  client_cidr_block = "10.1.0.0/22" # must be at least /22
  server_certificate_arn = aws_acm_certificate.app_cert.arn
  split_tunnel = true

  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.app_cert.arn
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_security_group" "vpn_access" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    protocol = "UDP" # transport protocol for VPN
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming vpn connections"
  }

  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnet_associations" {
  count = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id = var.subnet_ids[count.index]
  security_groups = [aws_security_group.vpn_access.id]
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr = var.vpc_cidr
  authorize_all_groups = true
}
