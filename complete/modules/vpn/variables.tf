variable "vpc_id" {
  description = "ID for the VPC"
  type        = string
  default     = ""
}
variable "google_compute_address" {
  description = "Address for Google Compute"
  type        = string
  default     = ""
}

variable "aws_route_table_ids" {
  description = "Route table ids"
  type        = list
  default     = []
}
