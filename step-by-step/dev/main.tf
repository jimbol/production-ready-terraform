provider "aws" {
  region = "us-east-1"
  profile = "default"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-dev-10-6"
    region = "us-east-1"
    key = "terraform-state/dev/terraform.tfstate"

    dynamodb_table = "terraform-state-lock-dev-10-6"
  }
}

module "backend" {
  source      = "../modules/backend"
  env         = "dev"
}

locals {
  vpc_cidr = "10.0.0.0/16" # 10.0.0.0 - 10.0.255.255
  private_subnet = "10.0.1.0/24" # 10.0.1.0 - 10.0.1.255
  public_subnet = "10.0.2.0/24" # 10.0.2.0 - 10.0.2.255
}

module "vpc" {
  source = "../modules/vpc"
  vpc_cidr = local.vpc_cidr
  private_subnet = local.private_subnet
  public_subnet = local.public_subnet
  aws_vpn_gateway_id = module.site_to_site_vpn.aws_vpn_gateway_id
}

module "vpn" {
  source = "../modules/vpn"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = local.vpc_cidr
  subnet_ids = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
}

module "site_to_site_vpn" {
  source = "../modules/site-to-site-vpn"
  vpc_id = module.vpc.vpc_id
  google_vpn_address = module.google_cloud.google_vpn_address
  private_route_table_id = module.vpc.private_route_table_id
  public_route_table_id = module.vpc.public_route_table_id
}

module "google_cloud" {
  source = "../modules/google-cloud"
  aws_subnets = [local.private_subnet, local.public_subnet]
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
  name        = "allow_ssh"
  description = "Allow SSH"
  vpc_id = module.vpc.vpc_id
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      to_port          = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      to_port          = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "allow_ssh"
  }
}

# aws_instance - resource type. an ec2 instance
# test_server - how we refer to the resource within TF
resource "aws_instance" "test_server" {
  subnet_id     = module.vpc.public_subnet_id
  ami           = "ami-0c2b8ca1dad447f8a" # image for the ec2 instance
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  key_name= "terraformclass"

  tags = {
    Name = "Test Server Instance"
  }
}

resource "aws_eip" "test_server_eip" {
  vpc = true

  instance                  = aws_instance.test_server.id
  associate_with_private_ip = aws_instance.test_server.private_ip
  depends_on                = [module.vpc.public_internet_gateway]
}


resource "aws_security_group" "allow_ping" {
  name        = "allow_ping"
  description = "Allow Ping"
  vpc_id = module.vpc.vpc_id
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      to_port          = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      to_port          = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "allow_ssh"
  }
}


# Private EC2
resource "aws_instance" "private_test_server" {
  subnet_id     = module.vpc.private_subnet_id
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ping.id]

  key_name= "terraformclass"

  tags = {
    Name = "Private Test Server Instance"
  }
}
