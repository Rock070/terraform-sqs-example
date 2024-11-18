resource "aws_iam_role" "lambda_role" {
  name               = "lambda_sqs_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_function" "lambda_sqs_sender" {
  filename      = "functions/lambda-sqs-sender/dist-zip/lambda-sqs-sender.zip"
  function_name = "example-lambda-sender"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda-sqs-sender.handler"
  runtime       = "nodejs20.x"
  timeout       = 10

  source_code_hash = filebase64sha256("functions/lambda-sqs-sender/dist-zip/lambda-sqs-sender.zip")

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.main_queue.url
    }
  }
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_sqs_policy"
  description = "Policy for Lambda to send messages to SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}
