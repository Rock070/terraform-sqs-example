resource "aws_sqs_queue" "dlq" {
  name                      = "dlq-${var.env}.fifo"
  fifo_queue                = true
  message_retention_seconds = 345600
}

resource "aws_sqs_queue_redrive_policy" "queue_redrive_policy" {
  queue_url = aws_sqs_queue.main_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq_allow_policy" {
  queue_url = aws_sqs_queue.dlq.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.main_queue.arn]
  })
}

