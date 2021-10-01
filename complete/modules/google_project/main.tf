provider "google" {
  credentials = file(pathexpand("~/.config/gcloud/${var.project_id}.json"))
  region      = var.google_region
  project     = var.project_id
}

provider "google-beta" {
  credentials = file(pathexpand("~/.config/gcloud/${var.project_id}.json"))
  region      = var.google_region
  project     = var.project_id
}

# Enable this manually - https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_compute_network" "main" {
  project = google_project_service.compute.project

  name         = var.network_name
  routing_mode = "GLOBAL"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private" {
  project = google_project_service.compute.project

  name          = "private-${var.google_region}"
  ip_cidr_range = var.cidr_block
  region        = var.google_region
  network       = google_compute_network.main.self_link
}

resource "google_compute_router" "nat" {
  project = google_project_service.compute.project

  name    = "${var.google_region}-nat-router"
  region  = var.google_region
  network = google_compute_network.main.self_link
}

resource "google_compute_router_nat" "nat" {
  project = google_project_service.compute.project

  name                   = "${var.google_region}-nat"
  router                 = google_compute_router.nat.name
  region                 = var.google_region
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

locals {
  google_connection_name = "aws-vpn"
}

# Googles-side VPN configuration
resource "google_compute_address" "vpn" {
  project = var.project_id
  name    = "${local.google_connection_name}-ip"
  region  = var.google_region
}

resource "google_compute_vpn_gateway" "aws" {
  project = var.project_id
  name    = "${local.google_connection_name}-gw-${var.google_region}"
  network = data.google_compute_network.main.self_link
  region  = var.google_region
}


# Not sure if we need this for demo purposes
# Allows google instances to resolve aws private domains
# resource "google_dns_managed_zone" "aws" {
#   provider = google-beta

#   project = google_project_service.compute.project

#   name        = "aws"
#   description = "private dns zone to enable resolving ec2 private domains"

#   dns_name = "${var.aws_dns_suffix}."

#   visibility = "private"

#   private_visibility_config {
#     networks {
#       network_url =  google_compute_network.main.self_link
#     }
#   }

#   forwarding_config {
#     target_name_servers {
#       ipv4_address = var.aws_dns_ip_addresses[0]
#     }

#     target_name_servers {
#       ipv4_address = var.aws_dns_ip_addresses[1]
#     }
#   }
# }
