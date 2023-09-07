# Lab 1 - EC2
# Class: AIT 665 - Cloud Computing
# Author: Christopher Wagner

# ---------------------------------------
# DEFINE PROVIDER CONIGURATION W/ REGION
# ---------------------------------------
provider "aws" {
  region = "us-east-1"
}


# ---------------------------------------
# GET THE AMI ID FOR AMAZON LINUX 2
# ---------------------------------------
data "aws_ami" "amzn2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# ---------------------------------------
# CREATE A VPC TO DEPLOY THE EC2 INSTANCE
# ---------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "ec2-Lab1"
  cidr = "10.0.0.0/18"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}


# ---------------------------------------
# CREATE A SECURITY GROUP FOR THE INSTANCE
# ---------------------------------------
resource "aws_security_group" "ec2" {
  name = "lab1-firewalls"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
  }

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"
  }

  egress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
  }
}


# ---------------------------------------
# CREATE A KEY PAIR FOR THE INSTANCE
# ---------------------------------------
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "ec2-Lab1"
  public_key = tls_private_key.ssh.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.ssh.private_key_pem}' > ec2-Lab1.pem
      chmod 400 ./ec2-Lab1.pem
    EOT
  }
}


# ---------------------------------------
# CREATE AN IAM ROLE FOR THE INSTANCE
# ---------------------------------------
resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-Lab1"

  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "ec2" {
  name = "ec2-Lab1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# ---------------------------------------
# CREATE THE EC2 INSTANCE
# ---------------------------------------
resource "aws_instance" "ec2" {
  ami = data.aws_ami.amzn2.id

  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2.name
  key_name             = aws_key_pair.ssh.key_name

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]

  associate_public_ip_address = true

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 14
    delete_on_termination = true
  }

  tags = {
    Name = "ec2-Lab1"
  }

  depends_on = [aws_security_group.ec2]
}
