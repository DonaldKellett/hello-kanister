resource "local_file" "time-logger-configmap" {
  content         = <<EOT
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: time-logger-s3-location
  namespace: kanister
data:
  region: ${var.region}
  path: s3://${aws_s3_bucket.hello-kanister.bucket}/time-logger
EOT
  filename        = "${path.module}/time-logger/configmap.yaml"
  file_permission = "0666"
}

resource "local_sensitive_file" "time-logger-secret" {
  content         = <<EOT
---
apiVersion: v1
kind: Secret
metadata:
  name: time-logger-aws-creds
  namespace: kanister
type: Opaque
data:
  aws_access_key_id: ${base64encode(aws_iam_access_key.hello-kanister.id)}
  aws_secret_access_key: ${base64encode(aws_iam_access_key.hello-kanister.secret)}
EOT
  filename        = "${path.module}/time-logger/secret.yaml"
  file_permission = "0600"
}
