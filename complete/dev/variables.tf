variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "env" {
  description = "Environment"
  default     = "dev"
}

variable "db_subnets" {
  description = "db subnets"
  default     = ["10.10.21.0/24", "10.10.22.0/24"]
}

