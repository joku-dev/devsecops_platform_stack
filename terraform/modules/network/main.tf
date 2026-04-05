variable "environment" {
  type = string
}

variable "cidr_block" {
  type = string
}

locals {
  name = "network-${var.environment}"
}

output "name" {
  value = local.name
}

output "cidr_block" {
  value = var.cidr_block
}
