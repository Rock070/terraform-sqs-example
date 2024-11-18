
# IAM Role 供 Lambda 使用
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 附加 IAM Role 給予 Lambda SQS 權限
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.main_queue.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 创建 Lambda 函数
resource "aws_lambda_function" "example_lambda" {
  filename         = "functions/lambda-sqs/dist-zip/lambda-sqs.zip" # 提前打包的 Lambda ZIP
  function_name    = "example-lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda-sqs.handler"
  runtime          = "nodejs20.x"         
  source_code_hash = filebase64sha256("functions/lambda-sqs/dist-zip/lambda-sqs.zip")

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.main_queue.id
    }
  }
}

