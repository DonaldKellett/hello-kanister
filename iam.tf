resource "aws_iam_policy" "hello-kanister" {
  name        = "hello-kanister"
  description = "Policy for hello-kanister-${random_id.hello-kanister-suffix.hex} S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.hello-kanister.arn,
          "${aws_s3_bucket.hello-kanister.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_group" "hello-kanister" {
  name = "hello-kanister"
}

resource "aws_iam_group_policy_attachment" "hello-kanister" {
  group      = aws_iam_group.hello-kanister.name
  policy_arn = aws_iam_policy.hello-kanister.arn
}

resource "aws_iam_user" "hello-kanister" {
  name = "hello-kanister"
}

resource "aws_iam_user_group_membership" "hello-kanister" {
  user   = aws_iam_user.hello-kanister.name
  groups = [aws_iam_group.hello-kanister.name]
}

resource "aws_iam_access_key" "hello-kanister" {
  user = aws_iam_user.hello-kanister.name
}
