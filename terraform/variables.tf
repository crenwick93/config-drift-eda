variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

variable "managed_node_instance_type" {
  description = "Instance type for the RHEL managed node"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into the managed node (your IP + AAP controller)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "demo_domain" {
  description = "Base domain with an existing Route53 hosted zone (e.g. sandbox2797.opentlc.com)"
  type        = string
}

variable "managed_node_hostname" {
  description = "Hostname prefix for the managed node — becomes <hostname>.<demo_domain>"
  type        = string
  default     = "rhel-drift"
}

variable "vpc_id" {
  description = "VPC ID to deploy into. Leave empty to use the default VPC."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance. Leave empty to use the first default subnet."
  type        = string
  default     = ""
}
