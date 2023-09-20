# Lab 1 - IAM and S3
# Class: AIT 665 - Cloud Computing
# Author: Christopher Wagner


data "aws_caller_identity" "current" {}

# ---------------------------------------
# DEFINE PROVIDER CONIGURATION W/ REGION
# ---------------------------------------
provider "aws" {
  region = "us-east-1"
}


# ---------------------------------------
# DEFINE IAM USER
# ---------------------------------------
resource "aws_iam_user" "lab2" {
  name          = "AIT670student"
  force_destroy = true

  tags = {
    Title = "Developer"
    Email = "aituser1@ait670TU.com"
  }
}





# ---------------------------------------
# SET CONSOLE LOGIN PASSWORD
# ---------------------------------------
resource "aws_iam_user_login_profile" "lab2" {
  user = aws_iam_user.lab2.name

  password_length = 20
}


# ---------------------------------------
# DEFINE IAM USER GROUP
# ---------------------------------------
resource "aws_iam_group" "lab2" {
  name = "AIT670Group"
}


# ---------------------------------------
# ATTACH POLICY TO GROUP
# ---------------------------------------
data "aws_iam_policy" "lab2" {
  name = "AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "lab2" {
  group      = aws_iam_group.lab2.name
  policy_arn = data.aws_iam_policy.lab2.arn
}


# ---------------------------------------
# ATTACH USER TO GROUP
# ---------------------------------------

resource "aws_iam_user_group_membership" "lab2" {
  user = aws_iam_user.lab2.name

  groups = [
    aws_iam_group.lab2.name
  ]
}
