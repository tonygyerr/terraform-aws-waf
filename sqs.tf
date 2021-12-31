resource "aws_sqs_queue" "deadletter" {
  name                              = "${var.app_name}-deadletter-queue"
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue" "waf" {
  name                      = "${var.app_name}-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "production"
  }
}