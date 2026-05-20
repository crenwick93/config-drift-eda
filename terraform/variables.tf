variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "aap_instance_type" {
  description = "Instance type for the AAP + EDA controller host"
  type        = string
  default     = "t3.xlarge"
}

variable "managed_node_instance_type" {
  description = "Instance type for RHEL managed nodes"
  type        = string
  default     = "t3.micro"
}

variable "managed_node_count" {
  description = "Number of RHEL managed nodes to provision"
  type        = number
  default     = 2
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into all instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "splunk_cloud_egress_cidrs" {
  description = "Splunk Cloud egress IP ranges for webhook delivery (lock down EDA port)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with actual Splunk Cloud egress IPs after trial registration
}

variable "vpc_id" {
  description = "VPC ID to deploy into. Leave empty to use the default VPC."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instances. Leave empty to use the first default subnet."
  type        = string
  default     = ""
}
