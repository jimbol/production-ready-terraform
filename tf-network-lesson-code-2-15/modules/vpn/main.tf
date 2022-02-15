resource "aws_acm_certificate" "vpn_certificate" {
  certificate_body = file("~/tfclass/server.crt")
  private_key = file("~/tfclass/server.key")
  certificate_chain = file("~/tfclass/ca.crt")
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = "Vpn endpoint that we will use to connect to our network"

  client_cidr_block = "10.1.0.0/22"
  server_certificate_arn = aws_acm_certificate.vpn_certificate.arn
  split_tunnel = true

  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.vpn_certificate.arn
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_security_group" "vpn_access" {
  vpc_id = var.vpc_id

  ingress = [{
    protocol = "UDP"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming vpn connection"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  egress = [{
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
    to_port = 0
    from_port = 0
    description = "internet egress"

    self             = false
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
  }]
}

resource "aws_ec2_client_vpn_network_association" "vpn_network_association" {
  count = length(var.subnet_ids)
  subnet_id = var.subnet_ids[count.index]
  security_groups = [aws_security_group.vpn_access.id]
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  target_network_cidr = var.vpc_cidr
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  authorize_all_groups = true
}
