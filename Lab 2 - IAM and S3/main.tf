# Lab 1 - IAM and S3
# Class: AIT 665 - Cloud Computing
# Author: Christopher Wagner


data "aws_partition" "current" {}

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
# CREATE ACCESS KEY/SECRET FOR USER
# ---------------------------------------
resource "aws_iam_access_key" "lab2" {
  user = aws_iam_user.lab2.name
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

# THIS SECTION IS BONUS WORK FOR LAB 2

# IT WILL USE A PROVIDER ALIAS OF THE CREATED

# IAM USER TO CREATE AN S3 BUCKET

# ---------------------------------------

provider "aws" {
  alias      = "ait670student"
  region     = "us-east-1"
  access_key = aws_iam_access_key.lab2.id
  secret_key = aws_iam_access_key.lab2.secret
}


# ---------------------------------------
# DEFINE S3 BUCKET
# ---------------------------------------

local {
  number_of_buckets = 3
}

resource "random_id" "bonus" {
  count = local.number_of_buckets
}

resource "aws_s3_bucket" "bonus" {
  count    = local.number_of_buckets
  provider = aws.ait670student

  bucket = "ait670student-${random_id.bonus[count.index].id}"
  tags = {
    Environment = "Test"
  }

  depends_on = [
    aws_iam_access_key.lab2
  ]
}


# ---------------------------------------
# ADD SOME FILES TO THE BUCKET
# ---------------------------------------

resource "local_file" "bonus" {
  filename = "index.html"
  content  = "<html><body><h1>Hello World!</h1></body></html>"
}

resource "aws_s3_bucket_object" "bonus" {
  provider = aws.ait670student

  bucket = aws_s3_bucket.bonus.id
  key    = "index.html"
  source = local_file.bonus.filename

  depends_on = [
    aws_iam_access_key.lab2
  ]
}


# ---------------------------------------
# CREATE IAM USERS WITH LIMITED ACCESS
# ---------------------------------------

locals {
  number_of_users = 2
}

resource "aws_iam_user" "bonus" {
  count    = local.number_of_users
  provider = aws.ait670student

  name = "ait670student-${count.index + 1}"

  depends_on = [
    aws_iam_access_key.lab2

  ]
}

resource "aws_iam_user_policy" "bonus" {
  count    = local.number_of_users
  provider = aws.ait670student

  name   = "${aws_s3_bucket.bonus.id}-read-only"
  user   = aws_iam_user.bonus[count.index].name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt${count.index + 1}",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.lab2.id}",
        "arn:aws:s3:::${aws_s3_bucket.lab2.id}/*"
      ]
    }
  ]
}
EOF

  depends_on = [
    aws_iam_access_key.lab2
  ]
}
