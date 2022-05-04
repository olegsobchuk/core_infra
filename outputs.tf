output "web_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web[0].public_ip
}

output "instance_private" {
  description = "EC2 private instance"
  value       = aws_instance.private[0]
}

output "web_public_url" {
  description = "Public URL of EC2 instance"
  value       = aws_instance.web[0].public_dns
}

output "ssh_login" {
  description = "Command for ssh connection to EC2 instance"
  value       = "ssh -i deploy_key ubuntu@${aws_instance.web[0].public_dns}"
}

output "s3" {
  value = aws_kms_key.kms_secret # aws_s3_bucket.deploy_bucket
}
