terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>3.0"
    }
  }

  backend "s3" {
    encrypt = true
    bucket = "terraform-class-2-15-dev-state"
    key = "terraform-state/dev/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-class-2-15-dev-state"
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
  google_vpc_cidr = "11.0.0.0/24"
}

module "backend" {
  source = "../modules/backend"
  env = local.env
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allows ssh connections and access to the internet"

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
  # subnet_id =
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  key_name = "terraformclass"

  tags = {
    name: "public test server"
  }
}
