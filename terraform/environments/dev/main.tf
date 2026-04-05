module "network" {
  source = "../../modules/network"

  environment = "dev"
  cidr_block  = "10.10.0.0/16"
}

module "object_storage" {
  source = "../../modules/object-storage"

  environment = "dev"
}
