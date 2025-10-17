output "ctfd_url" {
  description = "Public URL for your CTFd instance."
  value       = "https://${aws_route53_record.ctfd.fqdn}"
}

output "ec2_public_ip" {
  description = "EC2 public IP for SSH."
  value       = aws_instance.ctfd.public_ip
}

output "ssh_example" {
  description = "SSH command example (replace the key path with your private key)."
  value       = "ssh -i ~/.ssh/your_private_key.pem ubuntu@${aws_instance.ctfd.public_ip}"
}
