resource "aws_cloudwatch_event_rule" "example_rule" {
  name                = "example-event-rule"
  description         = "Trigger Lambda to process messages from SQS"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "example_target" {
  rule      = aws_cloudwatch_event_rule.example_rule.name
  target_id = "example-lambda-target"
  arn       = aws_lambda_function.example_lambda.arn
}

# EventBridge 給 Lambda 權限
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.example_rule.arn
}
