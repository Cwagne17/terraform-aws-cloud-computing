output "iam_user_username" {
  description = "IAM User's Username"
  value       = aws_iam_user.lab2.name
}

output "iam_user_password" {
  description = "IAM User's Password"
  value       = aws_iam_user_login_profile.lab2.password
}

output "aws_console_url" {
  description = "URL to AWS Sign-in Console"
  value       = "https://${data.aws_partition.current.partition}.signin.aws.amazon.com/console/"
}
