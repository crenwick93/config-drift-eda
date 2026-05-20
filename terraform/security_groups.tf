resource "aws_security_group" "aap_eda" {
  name_prefix = "config-drift-aap-eda-"
  description = "AAP + EDA controller — SSH, HTTPS, EDA webhook"
  vpc_id      = local.vpc_id

  tags = {
    Name = "config-drift-aap-eda"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "aap_ssh" {
  security_group_id = aws_security_group.aap_eda.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  description       = "SSH access"
}

resource "aws_security_group_rule" "aap_https" {
  security_group_id = aws_security_group.aap_eda.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "AAP Controller UI/API"
}

resource "aws_security_group_rule" "eda_webhook" {
  security_group_id = aws_security_group.aap_eda.id
  type              = "ingress"
  from_port         = 5001
  to_port           = 5001
  protocol          = "tcp"
  cidr_blocks       = var.splunk_cloud_egress_cidrs
  description       = "EDA webhook — lock to Splunk Cloud egress IPs in production"
}

resource "aws_security_group_rule" "aap_egress" {
  security_group_id = aws_security_group.aap_eda.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound — AAP needs Git, Galaxy, managed nodes, Splunk HEC"
}

resource "aws_security_group" "managed_node" {
  name_prefix = "config-drift-managed-"
  description = "RHEL managed nodes — SSH from AAP + admin"
  vpc_id      = local.vpc_id

  tags = {
    Name = "config-drift-managed"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "managed_ssh_admin" {
  security_group_id = aws_security_group.managed_node.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  description       = "SSH from admin"
}

resource "aws_security_group_rule" "managed_ssh_aap" {
  security_group_id        = aws_security_group.managed_node.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.aap_eda.id
  description              = "SSH from AAP controller for automation"
}

resource "aws_security_group_rule" "managed_egress" {
  security_group_id = aws_security_group.managed_node.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound — UF needs Splunk Cloud, yum needs repos"
}
