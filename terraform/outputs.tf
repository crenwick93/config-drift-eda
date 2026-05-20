output "managed_node_public_ip" {
  description = "Public IP of the RHEL managed node"
  value       = aws_instance.managed_node.public_ip
}

output "managed_node_private_ip" {
  description = "Private IP of the RHEL managed node"
  value       = aws_instance.managed_node.private_ip
}

output "managed_node_fqdn" {
  description = "DNS name for the managed node"
  value       = aws_route53_record.managed_node.fqdn
}

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key.filename
}

output "ssh_command" {
  description = "SSH command to connect to the managed node"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_route53_record.managed_node.fqdn}"
}
