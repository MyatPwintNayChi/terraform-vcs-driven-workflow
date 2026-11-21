data "aws_ami" "be_private_instance_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "backend_private_instance01" {
  ami                    = data.aws_ami.be_private_instance_ami.id
  instance_type          = var.be_instance_type
  key_name               = aws_key_pair.be_keypair.key_name
  subnet_id              = data.terraform_remote_state.backend_network.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.backend_security_groups.outputs.be_private_sg01_id]

  tags = {
    Name        = "${var.backend_prefix}-private-instance01"
    environment = "${var.backend_environment}"
  }
}

#####################################################
resource "null_resource" "configure-be-private-instance01" {
  depends_on = [aws_instance.backend_public_instance01, aws_eip_association.be_public_instance_eip_assoc]
  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "${path.module}/files/"
    destination = "/home/ubuntu/"
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = aws_instance.backend_private_instance01.private_ip
      private_key         = tls_private_key.be_keypair.private_key_pem
      bastion_host        = aws_eip.backend_public_instance_eip.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = tls_private_key.be_keypair.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      # Only install cowsay if not present
      "if ! command -v cowsay >/dev/null 2>&1; then sudo apt -y install cowsay; fi",
      "cowsay Hellooooooooooo!",
      # Only install unzip if not present
      "if ! command -v unzip >/dev/null 2>&1; then sudo apt -y install unzip; fi",
      # Only install AWS CLI v2 if not already installed
      <<-EOT
      if ! aws --version 2>/dev/null | grep 'aws-cli/2.'; then
        sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip;
        sudo unzip -o awscliv2.zip;
        sudo ./aws/install --update;
        sudo rm -rf awscliv2.zip aws;
      fi
      EOT
      ,
      "sudo aws --version",
    ]
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = aws_instance.backend_private_instance01.private_ip
      private_key         = tls_private_key.be_keypair.private_key_pem
      bastion_host        = aws_eip.backend_public_instance_eip.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = tls_private_key.be_keypair.private_key_pem
    }
  }
}

#####################################################
resource "aws_instance" "backend_private_instance02" {
  ami                    = data.aws_ami.be_private_instance_ami.id
  instance_type          = var.be_instance_type
  key_name               = aws_key_pair.be_keypair.key_name
  subnet_id              = data.terraform_remote_state.backend_network.outputs.private_subnet_ids[1]
  vpc_security_group_ids = [data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id]

  tags = {
    Name        = "${var.backend_prefix}-private-instance02"
    environment = "${var.backend_environment}"
  }
}

resource "aws_instance" "backend_private_instance03" {
  ami                    = data.aws_ami.be_private_instance_ami.id
  instance_type          = var.be_instance_type
  key_name               = aws_key_pair.be_keypair.key_name
  subnet_id              = data.terraform_remote_state.backend_network.outputs.private_subnet_ids[2]
  vpc_security_group_ids = [data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id]

  tags = {
    Name        = "${var.backend_prefix}-private-instance03"
    environment = "${var.backend_environment}"
  }
}
