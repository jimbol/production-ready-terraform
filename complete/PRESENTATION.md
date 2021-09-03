## Pre req
- Create AWS account
- Install AWS CLI
- Install Terraform

## Getting started
- Set up folders
  - Discuss folder stucture

- Create provider
  - Hard code region first
  - Set up variable file and variable for the region

- Add EC2 instance
  - Look at terraform.tfstate that is generated
  - Terraform generates a static configuration called the terraform state
  - When using the state to run, terraform can deploy deterministically. It will deploy the same resources each time based on the config
  - This is where TF keep track of what is deployed and where. It is a reflection of what is in live in your provider

- Discuss storing state remotely
  - This state isn't too useful if we cannot collaborate using it.
  - We can store the state remotely using terraform's "backend system"

- Create back end
  - Discuss modules in Terraform
  - set up s3 bucket
  - Set up state lock table in dynamodb

- Why use VPC
  - Its how you create a network on AWS.
  - Allows secure connection to on-premisis networks
  - Provides security options
- Break

- Understanding VPCs
  - Architectural Overview
    - Create subnets assign CIDR block (or an IP range) to each
    - Discuss connecting to the internet
  - How IPv4 CIDR blocks work - Quick version
    - Ranges of IP addresses
    - Some are reserved for the public internet
    - Network 10.0.0.0/16 - 32bit - 16 = 16. 2^16 = 65536
      - 10.0.0.0 - 10.0.255.255
    - Private subnet 10.0.1.1 - 10.0.1.254
    - Public subnet 10.0.2.1 - 10.0.2.254

- Set up VPC
  - Pick CIDR block
  - Deploy it and see it in AWS
  - Create Public Subnet
  - Create Private Subnet

- Public subnet
  - Set up internet gateway, attach to public subnet via a route table
    - Set up internet gateway.
      - Used for incoming AND outgoing traffic.
      - Use for apis
    - TODO add EC2 to public subnet and test

- Private subnet
  - Create a NAT Gateway and add it to the public subnet
    - Creat an Elastic IP
      - IP that will be used when making requests to the internet
    - The NAT Gateway needs to be in the public subnet so that it can reach the internet
  - Add Route table for Private subnet that points outgoing traffic to the nat gateway

