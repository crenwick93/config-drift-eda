# SSH key pair — generated and saved locally, never committed
resource "tls_private_key" "managed_node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "managed_node" {
  key_name   = "config-drift-${var.managed_node_hostname}"
  public_key = tls_private_key.managed_node.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.managed_node.private_key_pem
  filename        = "${path.module}/config-drift-${var.managed_node_hostname}.pem"
  file_permission = "0600"
}

resource "aws_instance" "managed_node" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = var.managed_node_instance_type
  key_name               = aws_key_pair.managed_node.key_name
  vpc_security_group_ids = [aws_security_group.managed_node.id]
  subnet_id              = local.subnet_id

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.managed_node_hostname}.${var.demo_domain}"
    Role = "managed-node"
  }
}

# Route53 A record so the node has a stable FQDN
data "aws_route53_zone" "demo" {
  name = var.demo_domain
}

resource "aws_route53_record" "managed_node" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "${var.managed_node_hostname}.${var.demo_domain}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.managed_node.public_ip]
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
