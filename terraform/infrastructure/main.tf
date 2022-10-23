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
