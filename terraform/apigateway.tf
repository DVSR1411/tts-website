module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.my_rest_api.id
  api_resource_id = aws_api_gateway_resource.api_resource.id
  allow_methods = ["OPTIONS","POST"]
  allow_max_age = 300
  depends_on = [ 
    aws_api_gateway_rest_api.my_rest_api,
    aws_api_gateway_resource.api_resource 
  ]
}
resource "aws_api_gateway_rest_api" "my_rest_api" {
  name        = "mytest"
  description = "Text to Speech API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  parent_id   = aws_api_gateway_rest_api.my_rest_api.root_resource_id
  path_part   = "test"
}
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_rest_api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.my_rest_api.id
  resource_id             = aws_api_gateway_method.post_method.resource_id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_rest_api.execution_arn}/*/*/*"
}
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_method.post_method,
    aws_api_gateway_integration.lambda,
    module.cors
  ]
}
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_rest_api.id
  stage_name    = "prod"
}
output "api_endpoint" {
  value = "${aws_api_gateway_stage.api_stage.invoke_url}/test"
}
