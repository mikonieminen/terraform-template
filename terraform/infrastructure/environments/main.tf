# module "prod" {
#   source = "./prod"
# }

# module "test" {
#   source = "./test"
# }

module "default" {
  source = "./default"
}

locals {
  envs = {
    # prod = module.prod
    # test = module.test
    default = module.default
  }
}

output "name" {
  value = terraform.workspace
}

output "zone_id" {
  value = local.envs[terraform.workspace].zone_id
}
