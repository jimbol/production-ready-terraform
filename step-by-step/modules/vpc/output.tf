output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.cloud_network.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "public_internet_gateway" {
  description = "The internet gateway for the public subnet"
  value = aws_internet_gateway.public_internet_gateway
}

output "private_route_table_id" {
  description = "The id for the private route table"
  value = aws_route_table.private_route_table.id
}

output "public_route_table_id" {
  description = "The id for the public route table"
  value = aws_route_table.public_route_table.id
}
