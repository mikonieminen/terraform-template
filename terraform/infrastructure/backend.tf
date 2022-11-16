locals {
  backend_app_port = 3000
}

### INSTANCES ###

data "template_cloudinit_config" "backend" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./files/backend/cloudinit.cfg.tmpl", {
      hostname                             = "backend"
      admin_keys                           = local.admin_keys
      start_backend_script_content         = file("./files/backend/start-backend.sh")
      backend_systemd_service_file_content = file("./files/backend/backend.service")
      backend_systemd_env_file_content = templatefile("./files/backend/backend.env.tmpl", {
        # NOTE: the AMI we use, has node.js lts/gallium pre-installed
        node_version = "lts/gallium"
        port         = local.backend_app_port
      })
      app_bundle_data = base64encode(file("./files/backend/example-node-app-v20221116-bd903e4.tgz"))
    })
  }
}

resource "aws_instance" "backend" {
  ami           = module.env.instances.backend.ami
  instance_type = module.env.instances.backend.instance_type

  key_name = var.deployment_key_name

  // TODO: how to make this to match with the DB instance AZ
  subnet_id = aws_subnet.private_subnet_a.id

  user_data = data.template_cloudinit_config.backend.rendered

  vpc_security_group_ids = [
    aws_security_group.backend_instance.id,
  ]

  // We want to control manually when to recreate these, by using `terraform taint`
  lifecycle {
    ignore_changes = [user_data, key_name]
  }

  tags = {
    Name = "backend-${module.env.name}"
    Env  = module.env.name
  }
}

output "backend" {
  value = {
    name            = aws_instance.backend.tags.Name
    instance_id     = aws_instance.backend.id
    state           = aws_instance.backend.instance_state
    public_address  = aws_instance.backend.public_dns
    private_address = aws_instance.backend.private_dns
    az              = aws_instance.backend.availability_zone
    taint_command   = "terraform taint aws_instance.backend"
  }
}
