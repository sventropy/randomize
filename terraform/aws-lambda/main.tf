provider "aws" {
  region = "eu-central-1"
}

resource "aws_lambda_function" "function" {
  function_name = var.function_name
  s3_bucket     = "${var.function_name}-lambda"
  s3_key        = "${var.function_name}.zip"
  handler       = "randomize::Lambda.LambdaEntryPoint::Init"
  runtime       = "dotnetcore3.1"
  role          = aws_iam_role.lambda_exec.arn
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs, aws_cloudwatch_log_group.log_group]
  tags          = var.tags
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}_lambda_execution_role"
  tags               = var.tags
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

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.function_name}"
  tags              = var.tags
  retention_in_days = 3
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# API Gateway

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_integration" "api-integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "${var.function_name}-api-integration"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.function.invoke_arn
}

resource "aws_apigatewayv2_route" "api-route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.api-integration.id}"
}

resource "aws_apigatewayv2_stage" "api-stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "default"
  auto_deploy = true
  tags        = var.tags
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format          = "{\"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"routeKey\":\"$context.routeKey\",\"status\":\"$context.status\"}"
  }
  #   default_route_settings {
  #     logging_level = "INFO"
  #   }
}

# Error: error updating API Gateway v2 stage (default): BadRequestException: Execution logs are not supported on protocolType HTTP

#   on main.tf line 95, in resource "aws_apigatewayv2_stage" "api-stage":
#   95: resource "aws_apigatewayv2_stage" "api-stage" {

output "api-endpoint" {
  value = "export AWS_ENDPOINT=${aws_apigatewayv2_api.api.api_endpoint}/default/randomize/graphql"
}





