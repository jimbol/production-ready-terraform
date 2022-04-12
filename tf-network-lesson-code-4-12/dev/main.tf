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
}

module "backend" {
  source = "../modules/backend"
  env = local.env
}

resource "aws_instance" "test_server" {
  ami = "ami-0f19d220602031aed"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "terraformclass"

  tags = {
    Name = "test server"
  }
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
