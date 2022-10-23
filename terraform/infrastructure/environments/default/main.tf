locals {
  # TODO: define zone ID that should be used for this env
  # probably match with the zone that's created at the aws-account side
  # or if created outsize the project, just provide the ID as a string
  zone_id = ""

  network = {
    vpc = {
      cidr_block = "10.1.0.0/16"
    }
    public_subnet_a = {
      name                  = "public-subnet-a"
      availability_zone     = "eu-central-1a"
      cidr_block            = "10.1.1.0/24"
      human_readable_region = "Frankfurt"
    }
    public_subnet_b = {
      name                  = "public-subnet-b"
      availability_zone     = "eu-central-1b"
      cidr_block            = "10.1.2.0/24"
      human_readable_region = "Frankfurt"
    }
    public_subnet_c = {
      name                  = "public-subnet-c"
      availability_zone     = "eu-central-1c"
      cidr_block            = "10.1.3.0/24"
      human_readable_region = "Frankfurt"
    }
    private_subnet_a = {
      name                  = "private-subnet-a"
      availability_zone     = "eu-central-1a"
      cidr_block            = "10.1.101.0/24"
      human_readable_region = "Frankfurt"
    }
    private_subnet_b = {
      name                  = "private-subnet-b"
      availability_zone     = "eu-central-1b"
      cidr_block            = "10.1.102.0/24"
      human_readable_region = "Frankfurt"
    }
    private_subnet_c = {
      name                  = "private-subnet-c"
      availability_zone     = "eu-central-1c"
      cidr_block            = "10.1.103.0/24"
      human_readable_region = "Frankfurt"
    }
  }
}

output "zone_id" {
  value = local.zone_id
}

output "network" {
  value = local.network
}
