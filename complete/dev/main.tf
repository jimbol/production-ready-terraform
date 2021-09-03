provider "aws" {
  region  = var.aws_region
  profile = "default"
}

# TEST EC2

# resource "aws_instance" "test_server" {
#   # You may need a different AMI for the region you are in
#   ami           = "ami-0c2b8ca1dad447f8a"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "TestServerInstance"
#   }
# }

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-state-dev-8-30"
    region         = "us-east-1"
    key            = "terraform-state/dev/terraform.tfstate"
    applicationdb_table = "terraform-state-lock-dev"
  }
}

module "backend" {
  source =    "../modules/backend_setup"
  env    =    var.env
}

module "vpc" {
  source          = "../modules/vpc"
  vpc_cidr        = "10.0.0.0/16" # 10.0.0.0 - 10.0.255.255
  private_subnet  = "10.0.1.0/24" # 10.0.1.1 - 10.0.1.254
  public_subnet   = "10.0.2.0/24" # 10.0.2.1 - 10.0.2.254
}
