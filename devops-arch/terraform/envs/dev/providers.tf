provider "aws" {
  region = var.aws_region
}

# Automatically fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Generate a private SSH key locally
resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS
resource "aws_key_pair" "dev_key" {
  key_name   = "devops-aws-key"
  public_key = tls_private_key.dev_key.public_key_openssh
}

# Save the private key to your local folder with secure permissions
resource "local_file" "private_key" {
  content          = tls_private_key.dev_key.private_key_pem
  filename         = "${path.module}/devops-aws-key.pem"
  file_permission  = "0400"  # This fixes the SSH permission error permanently
}
