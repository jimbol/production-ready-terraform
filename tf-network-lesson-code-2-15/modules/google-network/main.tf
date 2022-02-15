locals {
  project_id = "terraform-class-327014"
  google_region = "us-east1"
  network_name = "terraform-class-network"
  compute_address = "11.0.0.100"
}

provider "google" {
  credentials = file(pathexpand("~/.config/gcloud/${local.project_id}.json"))
  region = local.google_region
  project = local.project_id
}

resource "google_compute_network" "google_cloud_network" {
  name                    = local.network_name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "google_subnet1" {
  name          = "google-subnet1"
  ip_cidr_range = var.cidr_block
  network       = google_compute_network.google_cloud_network.name
  region        = local.google_region
}

# Allow ping
resource "google_compute_firewall" "gcp-allow-icmp" {
  name    = "${google_compute_network.google_cloud_network.name}-gcp-allow-icmp"
  network = google_compute_network.google_cloud_network.name

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "0.0.0.0/0",
  ]
}

# Allow SSH for iperf testing.
resource "google_compute_firewall" "gcp-allow-ssh" {
  name    = "${google_compute_network.google_cloud_network.name}-gcp-allow-ssh"
  network = google_compute_network.google_cloud_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0",
  ]
}

# Allow traffic from the VPN subnets.
resource "google_compute_firewall" "gcp-allow-vpn" {
  name    = "${google_compute_network.google_cloud_network.name}-gcp-allow-vpn"
  network = google_compute_network.google_cloud_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

# Allow TCP traffic from the Internet.
resource "google_compute_firewall" "gcp-allow-internet" {
  name    = "${google_compute_network.google_cloud_network.name}-gcp-allow-internet"
  network = google_compute_network.google_cloud_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "0.0.0.0/0",
  ]
}

# Compute instance
resource "google_compute_address" "google_compute_ip" {
  name   = "google-compute-ip-${local.google_region}"
  region = local.google_region
}

resource "google_compute_instance" "test_gcp_instance" {
  name         = "test-gcp-instance${local.google_region}"
  machine_type = "e2-micro"
  zone         = "${local.google_region}-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.google_subnet1.name
    network_ip = local.compute_address

    access_config {
      # Static IP
      nat_ip = google_compute_address.google_compute_ip.address
    }
  }
}

# VPN
resource "google_compute_address" "gcp-vpn-ip" {
  name   = "gcp-vpn-ip"
  region = local.google_region
}

resource "google_compute_vpn_gateway" "gcp-vpn-gateway" {
  name    = "gcp-vpn-gateway-${local.google_region}"
  network = google_compute_network.google_cloud_network.name
  region  = local.google_region
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.gcp-vpn-ip.address
  target      = google_compute_vpn_gateway.gcp-vpn-gateway.id
}

# /*
#  * ----------VPN Tunnel1----------
#  */

resource "google_compute_vpn_tunnel" "gcp-tunnel1" {
  name          = "gcp-tunnel1"
  peer_ip       = var.aws_vpn_connection.tunnel1_address
  shared_secret = var.aws_vpn_connection.tunnel1_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.gcp-vpn-gateway.self_link

  router = google_compute_router.gcp-router1.name

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_router" "gcp-router1" {
  name    = "gcp-router1"
  region  = local.google_region
  network = google_compute_network.google_cloud_network.name
  bgp {
    asn = 65000
  }
}

resource "google_compute_router_peer" "gcp-router1-peer" {
  name            = "gcp-to-aws-bgp1"
  router          = google_compute_router.gcp-router1.name
  region          = google_compute_router.gcp-router1.region
  peer_ip_address = var.aws_vpn_connection.tunnel1_vgw_inside_address
  peer_asn        = "64512"
  interface       = google_compute_router_interface.router_interface1.name
}

resource "google_compute_router_interface" "router_interface1" {
  name       = "gcp-to-aws-interface1"
  router     = google_compute_router.gcp-router1.name
  region     = google_compute_router.gcp-router1.region
  ip_range   = "${var.aws_vpn_connection.tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp-tunnel1.name
}

# /*
#  * ----------VPN Tunnel2----------
#  */

resource "google_compute_vpn_tunnel" "gcp-tunnel2" {
  name          = "gcp-tunnel2"
  peer_ip       = var.aws_vpn_connection.tunnel2_address
  shared_secret = var.aws_vpn_connection.tunnel2_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.gcp-vpn-gateway.self_link

  router = google_compute_router.gcp-router2.name

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_router" "gcp-router2" {
  name    = "gcp-router2"
  region  = local.google_region
  network = google_compute_network.google_cloud_network.name
  bgp {
    asn = 65000
  }
}

resource "google_compute_router_peer" "gcp-router2-peer" {
  name            = "gcp-to-aws-bgp2"
  router          = google_compute_router.gcp-router2.name
  region          = google_compute_router.gcp-router2.region
  peer_ip_address = var.aws_vpn_connection.tunnel2_vgw_inside_address
  peer_asn        = "64512"
  interface       = google_compute_router_interface.router_interface2.name
}

resource "google_compute_router_interface" "router_interface2" {
  name       = "gcp-to-aws-interface2"
  router     = google_compute_router.gcp-router2.name
  region     = google_compute_router.gcp-router2.region
  ip_range   = "${var.aws_vpn_connection.tunnel2_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp-tunnel2.name
}
