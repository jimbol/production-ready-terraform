terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }

  # backend "s3" {
  #   encrypt = true
  #   bucket = "terraform-class-2-16-dev-state"
  #   key = "terraform-state/dev/terraform.tfstate"
  #   region = "us-east-2"

  #   dynamodb_table = "terraform-class-2-16-dev-state"
  # }
}

provider "aws" {
  region = "us-east-2"
  profile = "default"
}

locals {
  env = "dev"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  google_vpc_cidr = "11.0.0.0/24"
}

module "backend" {
  source = "../modules/backend"
  env = local.env
}

module "vpc" {
  source = "../modules/vpc"
  env = local.env
  vpc_cidr = local.vpc_cidr
}

module "vpn" {
  source = "../modules/vpn"
  subnet_ids = [module.vpc.private_subnet_id, module.vpc.public_subnet_id]
  vpc_id = module.vpc.vpc_id
  vpc_cidr = local.vpc_cidr
}

module "site_to_site_vpn" {
  source = "../modules/site-to-site-vpn"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = local.vpc_cidr
  google_vpc_cidr = local.google_vpc_cidr
  google_vpn_address = module.google_network.google_vpn_address
  aws_private_route_table_id = module.vpc.private_route_table_id
  aws_public_route_table_id = module.vpc.public_route_table_id
}

module "google_network" {
  source = "../modules/google-network"
  cidr_block = local.google_vpc_cidr
  aws_subnets = [local.private_subnet_cidr, local.public_subnet_cidr]
  aws_vpn_connection = {
    tunnel1_address = module.site_to_site_vpn.aws_vpn_connection.tunnel1_address,
    tunnel1_preshared_key = module.site_to_site_vpn.aws_vpn_connection.tunnel1_preshared_key,
    tunnel1_vgw_inside_address = module.site_to_site_vpn.aws_vpn_connection.tunnel1_vgw_inside_address,
    tunnel1_cgw_inside_address = module.site_to_site_vpn.aws_vpn_connection.tunnel1_cgw_inside_address,

    tunnel2_address = module.site_to_site_vpn.aws_vpn_connection.tunnel2_address,
    tunnel2_preshared_key = module.site_to_site_vpn.aws_vpn_connection.tunnel2_preshared_key,
    tunnel2_vgw_inside_address = module.site_to_site_vpn.aws_vpn_connection.tunnel2_vgw_inside_address,
    tunnel2_cgw_inside_address = module.site_to_site_vpn.aws_vpn_connection.tunnel2_cgw_inside_address,
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allows ssh connections and access to the internet"
  vpc_id = module.vpc.vpc_id

  ingress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    self = false

    ipv6_cidr_blocks = []
    security_groups  = []
    prefix_list_ids = []
  }]

  egress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "internet egress"
    protocol = "-1"
    from_port = 0
    to_port = 0

    self = false
    ipv6_cidr_blocks = []
    security_groups  = []
    prefix_list_ids = []
  }]
}

resource "aws_eip" "test_server_eip" {
  vpc = true
  instance = aws_instance.test_server.id
  associate_with_private_ip = aws_instance.test_server.private_ip
}

resource "aws_instance" "test_server" {
  ami = "ami-0f19d220602031aed"
  instance_type = "t2.nano"
  subnet_id = module.vpc.public_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  key_name = "terraformclass"

  tags = {
    name: "public test server"
  }
}

resource "aws_instance" "private_test_server" {
  ami = "ami-0f19d220602031aed"
  instance_type = "t2.nano"
  subnet_id = module.vpc.private_subnet_id

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  key_name = "terraformclass"

  tags = {
    "name" = "private test server"
  }
}
