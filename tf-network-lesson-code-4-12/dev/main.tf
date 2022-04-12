terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }

  backend "s3" {
    encrypt = true
    bucket = "terraform-class-4-12-dev-tfstate"
    key = "terraform-state/dev/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-class-4-12-dev-lock"
  }
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
}

module "backend" {
  source = "../modules/backend"
  env = local.env
}

module "vpc" {
  source = "../modules/vpc"
  env = local.env
  vpc_cidr = local.vpc_cidr
  public_subnet_cidr = local.public_subnet_cidr
  private_subnet_cidr = local.private_subnet_cidr
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
    Name = "test server"
  }
}
resource "aws_instance" "private_test_server" {
  ami = "ami-0f19d220602031aed"
  instance_type = "t2.nano"
  subnet_id = module.vpc.private_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "terraformclass"

  tags = {
    Name = "private test server"
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
    description = "internet access"
    protocol = "-1"
    from_port = 0
    to_port = 0

    self = false
    ipv6_cidr_blocks = []
    security_groups  = []
    prefix_list_ids = []
  }]
}
