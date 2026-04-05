variable "environment" {
  type = string
}

locals {
  bucket_name = "artifacts-${var.environment}"
}

output "bucket_name" {
  value = local.bucket_name
}
