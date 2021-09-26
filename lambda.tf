resource "aws_iam_role" "lambda_role" {
  name               = "iam_role_lambda_function"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {

  name        = "iam_policy_lambda_logging_function"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = file("lambdapolicy.json")
}


resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "default" {
  type        = "zip"
  source_file = "${path.module}/tags_check.py"
  output_path = "${path.module}/python_tc.zip"
}


resource "aws_lambda_function" "lambdafunc" {
  filename      = "${path.module}/python_tc.zip"
  function_name = "check_tags_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.policy_attach]
}

resource "aws_cloudwatch_event_rule" "everyday" {
  name                = "evereday-run"
  description         = "Evereday run of lambda"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "check_tags" {
  rule      = aws_cloudwatch_event_rule.everyday.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambdafunc.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambdacheck" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdafunc.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.everyday.arn
}