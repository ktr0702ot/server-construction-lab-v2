output "ec2_public_ip" {
  description = "EC2のパブリックIP"
  value       = aws_instance.main.public_ip
}