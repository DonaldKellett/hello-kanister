output "hello-kanister-access-key" {
  value = aws_iam_access_key.hello-kanister.id
}

output "hello-kanister-secret-key" {
  value     = aws_iam_access_key.hello-kanister.secret
  sensitive = true
}
