# Lab 1 - EC2
# Class: AIT 665 - Cloud Computing
# Author: Christopher Wagner

# The region us-east-1 is located in North Virginia.
# It is the region closest to me and the one I deploy
# to most often.
#
# An AWS region is a physical geographic location in the
# world that contains a cluster of AWS data centers.
# 
# An AWS Availability Zone (AZ) is a distinct location 
# within an AWS Region that are engineered to be isolated 
# from failures in other Availability Zones. A single 
# AWS Region contains multiple Availability Zones.
# 
# The us-east-1 region contains the following AZs:
# us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e
provider "aws" {
  region = "us-east-1"
}


# An Amazon Machine Image (AMI) is a supported and 
# maintained image provided by AWS that provides the 
# information required to launch an instance.
#
# An AMI can be selected based on many criteria.
# The AMI can be selected based on the operating system,
# virtualization type, architecture, and storage for example.
# A full list of criteria can be found at the following link:
# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
#
# I chose the Amazon Linux 2 AMI because it was built specifically
# for running on AWS Cloud. In many ways it is optimized for security
# and performance. It is also free tier eligible.
#
# Under the Quickstart tab, there are three options for where to find AMIs:
#
# My AMIs is a list of AMIs that you have created or have been shared with you.
#
# AWS Marketplace is a list of AMIs that have been created by third parties
# that are verified by AWS.
#
# Community AMIs is a list of AMIs that are available for use that have been
# released for public use. These AMIs are not nessecarily verified by AWS.
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


# A security group acts as a virtual firewall for your 
# instance to control inbound (ingress) and outbound (egress) 
# traffic. A security group is stateful, meaning if you allow
# inbound traffic, return traffic is automatically allowed and
# vice versa.
resource "aws_security_group" "ec2" {
  name = "lab1-firewalls"
}

resource "aws_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.ec2.id

  from_port   = "80"
  ip_protocol = "tcp"
  to_port     = "80"
}

resource "aws_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ec2.id

  from_port   = "80"
  ip_protocol = "tcp"
  to_port     = "80"
}

# SSH Key

# A key pair is created an used to connect to the EC2 instance.
# If you lose the key pair, you will not be able to connect to
# the EC2 instance with SSH. However, there is an alternative
# method to connect to the EC2 instance through the AWS console.
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "ec2-Lab1"
  public_key = tls_private_key.example.public_key_openssh
}

# IAM Instance Profile

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

# EC2 Instance

resource "aws_instance" "ec2" {
  ami = data.aws_ami.amzn2.id

  # The different instance types represent different combinations of 
  # CPU, memory, storage, and networking capacity. Each instance type
  # includes one or more instance sizes, allowing you to scale your
  # resources to the requirements of your target workload.
  #
  # Additionally, the instance types are grouped into families based
  # on their general purpose. For example, the t2 family is designed
  # for general purpose computing, while the c5 family is designed
  # for compute-intensive workloads.
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

  # Tags are used to identify resources. They can be used to
  # identify resources for billing purposes, or to identify
  # resources for automation purposes. In the case of this 
  # Name tag, it is used to identify the EC2 instance in the
  # AWS console.
  tags = {
    Name = "ec2-Lab1"
  }
}
