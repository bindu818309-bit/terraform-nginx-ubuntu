output "instance_public_ip" {
  value       = aws_instance.nginx_server.public_ip
  description = "The public IP of your new Nginx web server"
}
