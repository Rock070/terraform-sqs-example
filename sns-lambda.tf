resource "aws_lambda_function" "lambda_sns" {
  filename         = "functions/lambda-sns/dist-zip/lambda-sns.zip"
  function_name    = "lambda-to-slack"
  handler          = "lambda-sns.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_sns_role.arn
  source_code_hash = filebase64sha256("functions/lambda-sns/dist-zip/lambda-sns.zip")

  environment {
    variables = {
      SLACK_WEBHOOK_URL = ""
    }
  }
}

resource "aws_iam_role" "lambda_sns_role" {
  name = "lambda_sns_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sns_policy" {
  name = "lambda_sns_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.sns_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attachment" {
  role       = aws_iam_role.lambda_sns_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn

  depends_on = [
    aws_iam_role.lambda_sns_role,
    aws_iam_policy.lambda_sns_policy
  ]
}

output "lambda_sns_policy_arn" {
  value = aws_iam_policy.lambda_sns_policy.arn
}
