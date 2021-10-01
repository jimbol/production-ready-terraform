output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.cloud_network.id
}

output "aws_route_table_ids" {
  description = "ids of the route tables for the VPC"
  value       = [
    aws_route_table.private_route_table.id,
    aws_route_table.public_route_table.id
  ]
}
