#Login resource (/login)
resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  parent_id   = aws_api_gateway_rest_api.football_api.root_resource_id
  path_part   = "login"
}

#Options method for login resource
resource "aws_api_gateway_method" "login_options" {
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

#Response headers for login to allow cors
resource "aws_api_gateway_method_response" "login_options_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.login_resource.id
  http_method = aws_api_gateway_method.login_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Lambda Integrations
# This integration allows the API Gateway to invoke the Lambda function
resource "aws_api_gateway_integration" "login_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.football_api.id
  resource_id             = aws_api_gateway_resource.login_resource.id
  http_method             = aws_api_gateway_method.login_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  depends_on = [aws_api_gateway_method_response.login_options_response]
}

#Integrate response headers with the login resource
resource "aws_api_gateway_integration_response" "login_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.login_resource.id
  http_method = aws_api_gateway_method.login_options.http_method
  status_code = aws_api_gateway_method_response.login_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization, X-Api-Key, X-Amz-Date, X-Amz-Security-Token'"
  }

  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.login_options_integration]
}


#POST method for login resource
resource "aws_api_gateway_method" "login_method" {
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

#Integration for POST method
resource "aws_api_gateway_integration" "login_integration" {
  rest_api_id             = aws_api_gateway_rest_api.football_api.id
  resource_id             = aws_api_gateway_resource.login_resource.id
  http_method             = aws_api_gateway_method.login_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.login_function.invoke_arn

  depends_on = [aws_lambda_function.login_function]
}

resource "aws_api_gateway_method_response" "login_post_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.login_resource.id
  http_method = aws_api_gateway_method.login_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "login_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.login_resource.id
  http_method = aws_api_gateway_method.login_method.http_method
  status_code = aws_api_gateway_method_response.login_post_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method.login_method, aws_api_gateway_method_response.login_post_response, aws_api_gateway_integration.login_integration]
}

#Permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw_invoke_login" {
  statement_id  = "AllowAPIGatewayInvokeLogin"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.football_api.execution_arn}/*/*"
  depends_on    = [aws_lambda_function.login_function]
}


#for options
# method.response.header.Access-Control-Allow-Headers -> 'Content-Type, Authorization, X-Api-Key, X-Amz-Date, X-Amz-Security-Token'
# method.response.header.Access-Control-Allow-Methods ->'OPTIONS,GET,POST'
# method.response.header.Access-Control-Allow-Origin -> '*'


