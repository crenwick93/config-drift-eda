output "aap_eda_public_ip" {
  description = "Elastic IP of the AAP + EDA controller"
  value       = aws_eip.aap_eda.public_ip
}

output "aap_eda_private_ip" {
  description = "Private IP of the AAP + EDA controller"
  value       = aws_instance.aap_eda.private_ip
}

output "managed_node_public_ips" {
  description = "Public IPs of RHEL managed nodes"
  value       = aws_instance.managed_node[*].public_ip
}

output "managed_node_private_ips" {
  description = "Private IPs of RHEL managed nodes"
  value       = aws_instance.managed_node[*].private_ip
}

output "eda_webhook_url" {
  description = "URL for Splunk webhook alert action (add to Splunk allow-list)"
  value       = "http://${aws_eip.aap_eda.public_ip}:5001/endpoint"
}
