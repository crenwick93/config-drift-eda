resource "aws_security_group" "managed_node" {
  name_prefix = "config-drift-managed-"
  description = "RHEL managed node - SSH from admin and AAP controller"
  vpc_id      = local.vpc_id

  tags = {
    Name = "config-drift-managed"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "managed_ssh" {
  security_group_id = aws_security_group.managed_node.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  description       = "SSH from admin and AAP controller"
}

resource "aws_security_group_rule" "managed_egress" {
  security_group_id = aws_security_group.managed_node.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound - UF needs Splunk Cloud, dnf needs repos"
}
