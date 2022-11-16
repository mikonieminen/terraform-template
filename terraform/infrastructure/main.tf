terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # When initializing execute the below command where `bucket` is the bucket name
  # defined in the `aws-account` side. You can get by running:
  # ```sh
  # cd ../aws-account/
  # terraform output terraform_backend_config
  # cd ../infrastructure
  # ```
  # Pick `bucket`, `region` and `dynamdb_table` from the previous output and
  # replace in the following command and execute the command:
  # ```sh
  # terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"
  # ```
  #
  # Doing it this way, none of these values are stored in plain text under version
  # control system. Alternatively, you could store these values in the `backend`
  # block and it's enough simply to run `terraform init`.

  backend "s3" {
    bucket         = ""
    key            = "infrastructure/terraform.tfstate"
    region         = ""
    encrypt        = true
    dynamodb_table = ""
  }
}

module "env" {
  source = "./environments"
}

provider "aws" {
  alias  = "cognito_certs"
  region = "us-east-1"
}

module "cognito_certs" {
  source = "./modules/cognito_certs"

  providers = {
    aws = aws.cognito_certs
  }

  zone                    = null
  validation_record_fqdns = []
  # TODO: once root zone and cognito is configure, uncomment these
  # zone                    = data.aws_route53_zone.root
  # validation_record_fqdns = [for record in aws_route53_record.auth_acm_validation : record.fqdn]
}

# Get latest Ubuntu Linux 22.04 AMI
data "aws_ami" "latest_ubuntu_linux_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {

  # Default admin keys that allow super user access to machines in this env
  admin_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+/dO8atoS6XEkz/fwMnooz3MynU5IpcqLuyiXkt31S miko@laptop:terraform-example",
  ]

  # SSH keys that can be used for SSH login through our bastion
  allowed_bastion_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+/dO8atoS6XEkz/fwMnooz3MynU5IpcqLuyiXkt31S miko@laptop:terraform-example",
  ]

  instances = {
    bastion = {
      ami           = data.aws_ami.latest_ubuntu_linux_2204.id
      instance_type = "t3a.micro"
    }
  }
}
