resource "aws_instance" "aap_eda" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = var.aap_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.aap_eda.id]
  subnet_id              = local.subnet_id

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "config-drift-aap-eda"
    Role = "aap-controller"
  }
}

resource "aws_instance" "managed_node" {
  count = var.managed_node_count

  ami                    = data.aws_ami.rhel9.id
  instance_type          = var.managed_node_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.managed_node.id]
  subnet_id              = local.subnet_id

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "config-drift-managed-${count.index + 1}"
    Role = "managed-node"
  }
}

resource "aws_eip" "aap_eda" {
  instance = aws_instance.aap_eda.id
  domain   = "vpc"

  tags = {
    Name = "config-drift-aap-eda-eip"
  }
}

locals {
  vpc_id    = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
  subnet_id = var.subnet_id != "" ? var.subnet_id : data.aws_subnets.default[0].ids[0]
}

data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.subnet_id == "" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
