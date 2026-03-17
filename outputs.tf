output "instance_public_ip" {
  description = "Public IP of the OpenClaw instance"
  value       = aws_instance.openclaw.public_ip
}

output "gateway_url" {
  description = "URL to access the OpenClaw gateway dashboard"
  value       = "http://${aws_instance.openclaw.public_ip}:18789"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.openclaw.public_ip}"
}
