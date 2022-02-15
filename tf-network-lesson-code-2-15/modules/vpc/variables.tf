variable "env" {
  description = "Env name"
  default = "dev"
  type = string
}

variable "vpc_cidr" {
  description = "Range of ip address available in the VPC"
  type = string
}
