output "google_vpn_address" {
  description = "The ip address for the compute instance"
  value       = google_compute_address.gcp-vpn-ip.address
}
