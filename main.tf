# 1. Tell Terraform to connect to AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 2. Find the official Ubuntu 20.04 image automatically
data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"] # Official ID for Ubuntu's parent company (Canonical)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# 3. Find your default AWS network (VPC) so we don't accidentally build a new one
resource "aws_default_vpc" "default" {}

# 4. Create the Security Group (The Fire Wall)
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-server-sg"
  vpc_id      =  aws_default_vpc.default.id

  # Allow HTTP web traffic (Port 80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH terminal access (Port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Crucial: Allow the server to talk OUTbound to the internet to download Nginx
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Create the EC2 Instance (The Virtual Machine)
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  # This script runs automatically the exact moment the server turns on
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Welcome to the Terraform-managed Nginx Server on Ubuntu</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "Terraform-Nginx-Ubuntu-Server"
  }
}
