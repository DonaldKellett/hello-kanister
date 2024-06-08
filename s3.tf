resource "aws_s3_bucket" "hello-kanister" {
  bucket = "hello-kanister-${random_id.hello-kanister-suffix.hex}"
}
