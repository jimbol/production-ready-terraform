output "google_vpn_address" {
  description = "ip address for the vpn"
  value = google_compute_address.gcp-vpn-ip.address
}
output "google_vpn_interfaces" {
  description = "ip address for the vpn"
  value = google_compute_ha_vpn_gateway.target_gateway.vpn_interfaces
}
