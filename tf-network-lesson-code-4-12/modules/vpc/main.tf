resource "aws_vpc" "cloud_network" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.env} Cloud Network"
    env = var.env
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "us-east-2c"
}

resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.cloud_network.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.cloud_network.id

  tags = {
    Name = "public route table"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.public_internet_gateway.id
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = var.private_subnet_cidr
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
}

resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
