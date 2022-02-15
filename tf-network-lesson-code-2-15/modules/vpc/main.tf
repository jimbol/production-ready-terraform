resource "aws_vpc" "cloud_network" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    name = "Cloud network"
    env = var.env
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2c"
}

resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.cloud_network.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.cloud_network.id

  route = [{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_internet_gateway.id

    carrier_gateway_id = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id = ""
    instance_id = ""
    ipv6_cidr_block = ""
    local_gateway_id = ""
    nat_gateway_id = ""
    network_interface_id = ""
    transit_gateway_id = ""
    vpc_endpoint_id = ""
    vpc_peering_connection_id = ""
  }]

  tags = {
    name = "Public route table"
  }
}

resource "aws_route_table_association" "public_subnet_route_table" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_eip" "elastic_ip_for_nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = aws_subnet.private_subnet.id
  allocation_id = aws_eip.elastic_ip_for_nat_gateway.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.cloud_network.id

  route = [{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id

    gateway_id = ""
    carrier_gateway_id = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id = ""
    instance_id = ""
    ipv6_cidr_block = ""
    local_gateway_id = ""
    network_interface_id = ""
    transit_gateway_id = ""
    vpc_endpoint_id = ""
    vpc_peering_connection_id = ""
  }]
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
