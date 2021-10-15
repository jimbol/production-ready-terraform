output "aws_vpn_connection" {
  description = "The aws vpn connection"
  value       = aws_vpn_connection.aws_google_vpn_connection
}

output "aws_vpn_gateway_id" {
  description = "The aws vpn connection"
  value       = aws_vpn_gateway.aws_vpn_gw.id
}
