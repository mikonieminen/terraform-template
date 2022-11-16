# uncomment to create bastion server that can be used as a SSH jump proxy

data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./files/bastion/cloudinit.cfg.tmpl", {
      hostname             = "bastion"
      admin_keys           = local.admin_keys
      allowed_bastion_keys = local.allowed_bastion_keys
    })
  }
}

resource "aws_instance" "bastion" {
  ami           = local.instances.bastion.ami
  instance_type = local.instances.bastion.instance_type

  key_name = var.deployment_key_name

  subnet_id = aws_subnet.public_subnet_a.id

  user_data = data.template_cloudinit_config.bastion.rendered

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]

  # We want to control manually when to recreate these, by using `terraform taint`
  lifecycle {
    ignore_changes = [ami, user_data, key_name]
  }

  tags = {
    Name = "bastion-${module.env.name}"
    Env  = module.env.name
  }
}

output "bastion" {
  value = {
    name            = aws_instance.bastion.tags.Name
    instance_id     = aws_instance.bastion.id
    state           = aws_instance.bastion.instance_state
    public_address  = aws_instance.bastion.public_dns
    private_address = aws_instance.bastion.private_dns
    az              = aws_instance.bastion.availability_zone
    taint_command   = "terraform taint aws_instance.bastion"
  }
}
