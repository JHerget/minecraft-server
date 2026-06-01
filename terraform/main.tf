provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  key_name = "minecraft-server"

  tags = {
    Project = var.project_name
  }
}

resource "tls_private_key" "minecraft" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "minecraft" {
  key_name   = local.key_name
  public_key = tls_private_key.minecraft.public_key_openssh

  tags = merge(local.tags, {
    Name = local.key_name
  })
}

resource "local_sensitive_file" "minecraft_private_key" {
  filename        = "${path.module}/${local.key_name}.pem"
  content         = tls_private_key.minecraft.private_key_openssh
  file_permission = "0600"
}

resource "aws_security_group" "minecraft" {
  name        = "${var.project_name}-sg"
  description = "Allow Minecraft traffic and optional SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Minecraft Java Edition"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = var.minecraft_allowed_cidrs
  }

  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []

    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-sg"
  })
}

resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minecraft.key_name
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    project_name = var.project_name
  })

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.tags, {
    Name = var.project_name
  })
}

resource "aws_eip" "minecraft" {
  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${var.project_name}-eip"
  })
}

resource "aws_eip_association" "minecraft" {
  instance_id   = aws_instance.minecraft.id
  allocation_id = aws_eip.minecraft.id
}
