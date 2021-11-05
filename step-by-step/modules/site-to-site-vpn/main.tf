# Creates a Virtual Private Gateway
# provides two VPN endpoints (tunnels) for automatic failovers
resource "aws_vpn_gateway" "aws_vpn_gw" {
  vpc_id = var.vpc_id
}

# Connects to the aws_vpn_gateway
# Lets the gateway know the ip address with which we are making a connection
resource "aws_customer_gateway" "aws_google_gw" {
  # Border Gateway Protocol (BGP) Autonomous System Number (ASN).
  # the protocol underlying the global routing system of the internet
  bgp_asn = 65000

  ip_address = var.google_vpn_address
  type = "ipsec.1" # ip security type. AWS will automatically encrypt traffic traveling over
  tags = {
    "Name" = "aws_google_gw"
  }
}

resource "aws_vpn_connection" "aws_google_vpn_connection" {
  vpn_gateway_id = aws_vpn_gateway.aws_vpn_gw.id
  customer_gateway_id = aws_customer_gateway.aws_google_gw.id
  type = "ipsec.1"
  static_routes_only = false # can be false because we're using BGP (Border Gateway Protocol)

  # local_ipv4_network_cidr is the network cidr that we will connect to
  # "local" meaning your the network youre connecting to
  local_ipv4_network_cidr = "11.0.0.0/24"
  remote_ipv4_network_cidr = "10.0.0.0/16"
  tags = {
    "Name" = "aws_google_vpn_connection"
  }
}


# Requests automatic route propagation between a VPN gateway and a route table.
resource "aws_vpn_gateway_route_propagation" "public_route_table_propagation" {
  route_table_id = var.public_route_table_id
  vpn_gateway_id = aws_vpn_gateway.aws_vpn_gw.id
}

resource "aws_vpn_gateway_route_propagation" "private_route_table_propagation" {
  route_table_id = var.private_route_table_id
  vpn_gateway_id = aws_vpn_gateway.aws_vpn_gw.id
}


# Allow PING testing.
# resource "aws_security_group" "aws-allow-icmp" {
#   name        = "aws-allow-icmp"
#   description = "Allow icmp access from anywhere"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 8
#     to_port     = 0
#     protocol    = "icmp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Allow traffic from the VPN subnets.
# resource "aws_security_group" "aws-allow-vpn" {
#   name        = "aws-allow-vpn"
#   description = "Allow all traffic from vpn resources"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Allow TCP traffic from the Internet.
# resource "aws_security_group" "aws-allow-internet" {
#   name        = "aws-allow-internet"
#   description = "Allow http traffic from the internet"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
