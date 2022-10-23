locals {
  # TODO: define zone ID that should be used for this env
  # probably match with the zone that's created at the aws-account side
  # or if created outsize the project, just provide the ID as a string
  zone_id = ""
}

output "zone_id" {
  value = local.zone_id
}
