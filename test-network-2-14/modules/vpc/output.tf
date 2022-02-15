output "vpc_id" {
  description = "The id of our vpc"
  value = aws_vpc.cloud_network.id
}

output "public_subnet_id" {
  description = "id of our public subnet"
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "id of our private subnet"
  value = aws_subnet.private_subnet.id
}

output "private_route_table_id" {
  description = "The id for the private route table"
  value = aws_route_table.private_route_table.id
}

output "public_route_table_id" {
  description = "The id for the public route table"
  value = aws_route_table.public_route_table.id
}
