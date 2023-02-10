resource "aws_instance" "web-server" {
  disable_api_termination     = true
  for_each                    = { for instance in var.instance_details : instance.instance_name => instance }
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids 
  root_block_device {
    volume_size           = each.value.volume_size
    delete_on_termination = var.boot_disk_delete_on_termination
  }

  user_data = <<EOF
#!/bin/bash
sudo adduser admin
sudo adduser admin --disabled-password
usermod -a -G sudo admin
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
EOF

tags = {
    Name = each.value.instance_name
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4690
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_secretsmanager_secret" "secret_key" {
  name_prefix = var.name_prefix
}

resource "aws_secretsmanager_secret_version" "secret_key_value" {
  secret_id= aws_secretsmanager_secret.secret_key.id
  secret_string = tls_private_key.key.private_key_pem
}