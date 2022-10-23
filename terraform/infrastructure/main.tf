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
    # By default we allow admin access to holder of the deployment key,
    # but this should be replaced with some other predefined keys as this
    # one changes per deployer.
    var.deployment_key_name
  ]

  # SSH keys that can be used for SSH login through our bastion
  allowed_bastion_keys = []

  instances = {
    bastion = {
      ami           = data.aws_ami.latest_ubuntu_linux_2204.id
      instance_type = "t3a.micro"
    }
  }
}
