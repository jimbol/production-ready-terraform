output "vpc_id" {
  description = "vpc id"
  value = aws_vpc.cloud_network.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}
output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}
