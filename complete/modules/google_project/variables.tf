variable "project_id" {
  description = "Google project id"
  type = string
  default = ""
}
variable "google_region" {
  description = "Region for the Google project"
  type = string
  default = ""
}

variable "network_name" {
  description = "Name for the network"
  type = string
  default = ""
}

variable "cidr_block" {
  description = "cidr block for subnet"
  type = string
  default = ""
}
