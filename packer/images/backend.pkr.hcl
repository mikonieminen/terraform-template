
variable "image" {
  type = object({
    ami-name-prefix = string
    ami-description = string
  })
  default = {
    ami-name-prefix = "backend"
    ami-description = "AMI for backend VM with node.js installed"
  }
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "source-image-selector" {
  type = object({
    filters = object({
      name                = string
      virtualization-type = string
      root-device-type    = string
    })
    most_recent = bool
    owners      = list(string)
  })
  default = {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

data "amazon-ami" "source-ami" {
  filters = {
    name                = var.source-image-selector.filters.name
    virtualization-type = var.source-image-selector.filters.virtualization-type
    root-device-type    = var.source-image-selector.filters.root-device-type
  }
  region      = var.region
  owners      = var.source-image-selector.owners
  most_recent = var.source-image-selector.most_recent
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "base" {
  ami_name                = "${var.image.ami-name-prefix}-${local.timestamp}"
  ami_description         = "${var.image.ami-description}"
  region                  = var.region
  instance_type           = "t3a.large"
  source_ami              = data.amazon-ami.source-ami.id
  ssh_username            = "ubuntu"
  temporary_key_pair_type = "ed25519"
  tags = {
    BaseImage = data.amazon-ami.source-ami.id
  }
}

build {
  sources = ["source.amazon-ebs.base"]
  provisioner "file" {
    source      = "${path.root}/../files/install-nvm-v0.39.1.sh"
    destination = "/tmp/install-nvm.sh"
  }
  provisioner "shell" {
    script = "${path.root}/../scripts/install-nodejs.sh"
  }
  provisioner "shell" {
    script = "${path.root}/../scripts/cleanup.sh"
  }
}
