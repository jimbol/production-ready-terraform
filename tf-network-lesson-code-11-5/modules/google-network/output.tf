output "google_vpn_address" {
  description = "ip address for the vpn"
  value = google_compute_address.gcp-vpn-ip.address
}
