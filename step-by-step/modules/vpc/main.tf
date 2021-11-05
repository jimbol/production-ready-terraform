resource "aws_vpc" "cloud_network" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = var.public_subnet
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
    Name = "Public Internet Gateway Route Table"
  }

}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


# PRIVATE SUBNET
resource "aws_eip" "elastic_ip_for_nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip_for_nat_gateway.id
  subnet_id = aws_subnet.private_subnet.id
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = var.private_subnet
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.cloud_network.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
