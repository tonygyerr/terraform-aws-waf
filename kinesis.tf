resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "aws-waf-logs-${local.name}"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.logging.arn
    bucket_arn = "arn:aws:s3:::${local.logging_bucket}"
    prefix     = "AWSLogs/${local.account_id}/WAF/${local.region}/"
  }
}
