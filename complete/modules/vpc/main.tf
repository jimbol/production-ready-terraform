resource "aws_vpc" "cloud_network" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default" # Indicates whether you share the hardware with other AWS users.
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id =  aws_vpc.cloud_network.id
  cidr_block = "${var.public_subnet}"
}

# Add Internet Gateway for incoming/outgoing internet traffic
resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id =  aws_vpc.cloud_network.id
}

# Route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id =  aws_vpc.cloud_network.id
    route {
      cidr_block = "0.0.0.0/0" # All IPs, this grants access to the wider internet
      gateway_id = aws_internet_gateway.public_internet_gateway.id
    }
}

# Connect public route table and subnet
resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "elastic_ip_for_nat_gateway" {
  vpc   = true
}

# Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip_for_nat_gateway.id

  # Add to the public subnet so that it can access the internet
  subnet_id = aws_subnet.public_subnet.id
}


# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id =  aws_vpc.cloud_network.id
  cidr_block = "${var.private_subnet}"
}


# Private subnet route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.cloud_network.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Route table Association with Private Subnet's
resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
