resource "aws_sqs_queue" "main_queue" {
  name                       = "main_queue-${var.env}.fifo"
  message_retention_seconds  = 172800
  fifo_queue                 = true
  receive_wait_time_seconds  = 5
  visibility_timeout_seconds = 120
}

data "aws_iam_policy_document" "sender_iam" {
  version = "2012-10-17"

  statement {
    sid    = "SQSSenderFromLambda"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sender_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "main_queue_policy" {
  queue_url = aws_sqs_queue.main_queue.id
  policy    = data.aws_iam_policy_document.sender_iam.json
}

output "main_queue_arn" {
  value = aws_sqs_queue.main_queue.arn
}

output "main_queue_id" {
  value = aws_sqs_queue.main_queue.id
}

output "queue_policy" {
  value = data.aws_iam_policy_document.sender_iam.json
}
