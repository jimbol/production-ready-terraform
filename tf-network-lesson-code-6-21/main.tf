terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }

  backend "s3" {
    encrypt = true
    bucket = "terraform-class-6-21-tfstate"
    key = "terraform-state/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-class-6-21-lock"
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "default"
}

locals {
  create_in_backend = terraform.workspace == "backend" ? 1 : 0
  create_in_other_envs = terraform.workspace == "backend" ? 0 : 1
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "backend" {
  count = local.create_in_backend
  source = "./modules/backend"
}

module "vpc" {
  count = local.create_in_other_envs
  source = "./modules/vpc"
  vpc_cidr = local.vpc_cidr
  public_subnet_cidr = local.public_subnet_cidr
  private_subnet_cidr = local.private_subnet_cidr
  env = terraform.workspace
}

module "vpn" {
  source = "./modules/vpn"

  count = local.create_in_other_envs
  env = terraform.workspace
  vpc_id = module.vpc[0].vpc_id
  subnet_ids = [module.vpc[0].public_subnet_id, module.vpc[0].private_subnet_id]
  vpc_cidr = local.vpc_cidr
}

# ec2
resource "aws_eip" "test_server_eip" {
  count = local.create_in_other_envs
  vpc = true
  instance = aws_instance.test_server[0].id
  associate_with_private_ip = aws_instance.test_server[0].private_ip
}

resource "aws_instance" "test_server" {
  count = local.create_in_other_envs
  ami = "ami-0f19d220602031aed"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.allow_ssh[0].id]
  subnet_id = module.vpc[0].public_subnet_id

  key_name = "terraformclass"

  # user_data = <<-EOF
  #   #!/bin/bash
  #   python3 -m http.server
  # EOF

  tags = {
    Name = "${terraform.workspace} test server"
  }
}

resource "aws_instance" "private_test_server" {
  count = local.create_in_other_envs
  ami = "ami-0f19d220602031aed"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.allow_ssh[0].id]
  subnet_id = module.vpc[0].private_subnet_id

  key_name = "terraformclass"

  # user_data = <<-EOF
  #   #!/bin/bash
  #   python3 -m http.server
  # EOF

  tags = {
    Name = "${terraform.workspace} private test server"
  }
}

resource "aws_security_group" "allow_ssh" {
  count = local.create_in_other_envs
  name = "allow_ssh"
  description = "Allows ssh connections and access to the outside internet"
  vpc_id = module.vpc[0].vpc_id


  ingress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22

    self = false
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids = []
  }]

  egress = [{
    cidr_blocks = ["0.0.0.0/0"]
    description = "internet egress"
    protocol = "-1"
    from_port = 0
    to_port = 0

    self = false
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids = []
  }]
}
