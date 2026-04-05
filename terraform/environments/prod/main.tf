module "network" {
  source = "../../modules/network"

  environment = "prod"
  cidr_block  = "10.20.0.0/16"
}

module "object_storage" {
  source = "../../modules/object-storage"

  environment = "prod"
}
