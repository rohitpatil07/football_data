resource "aws_api_gateway_resource" "refresh_token_resource" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  parent_id   = aws_api_gateway_rest_api.football_api.root_resource_id
  path_part   = "refresh"

  depends_on = [aws_api_gateway_rest_api.football_api]
}

resource "aws_api_gateway_method" "refresh_token_options" {
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  resource_id   = aws_api_gateway_resource.refresh_token_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"

}

resource "aws_api_gateway_method_response" "refresh_token_options_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.refresh_token_resource.id
  http_method = aws_api_gateway_method.refresh_token_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }

  depends_on = [aws_api_gateway_method.refresh_token_options]
}

resource "aws_api_gateway_integration" "refresh_token_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.football_api.id
  resource_id             = aws_api_gateway_resource.refresh_token_resource.id
  http_method             = aws_api_gateway_method.refresh_token_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  depends_on = [aws_api_gateway_method.refresh_token_options]

}

resource "aws_api_gateway_integration_response" "refresh_token_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.refresh_token_resource.id
  http_method = aws_api_gateway_method.refresh_token_options.http_method
  status_code = aws_api_gateway_method_response.refresh_token_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  response_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
  depends_on = [aws_api_gateway_integration.refresh_token_options_integration]
}

#POST method for refresh resource
resource "aws_api_gateway_method" "refresh_token_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  resource_id   = aws_api_gateway_resource.refresh_token_resource.id
  http_method   = "GET"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.refresh_token_resource]
}


#Integration for GET method
resource "aws_api_gateway_integration" "refresh_token_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.football_api.id
  resource_id             = aws_api_gateway_resource.refresh_token_resource.id
  http_method             = aws_api_gateway_method.refresh_token_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.refresh_token_function.invoke_arn

  depends_on = [aws_lambda_function.refresh_token_function, aws_api_gateway_method.refresh_token_get_method]
}

resource "aws_api_gateway_method_response" "refresh_token_get_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.refresh_token_resource.id
  http_method = aws_api_gateway_method.refresh_token_get_method.http_method
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

# #For refresh token
# resource "aws_api_gateway_method_response" "refresh_token_get_response_401" {
#   rest_api_id = aws_api_gateway_rest_api.football_api.id
#   resource_id = aws_api_gateway_resource.refresh_token_resource.id
#   http_method = aws_api_gateway_method.refresh_token_get_method.http_method
#   status_code = "401"

#   response_models = {
#     "application/json" = "Empty"
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#     "method.response.header.Access-Control-Allow-Headers" = true
#   }
# }

# #For 500
# resource "aws_api_gateway_method_response" "refresh_token_get_response_500" {
#   rest_api_id = aws_api_gateway_rest_api.football_api.id
#   resource_id = aws_api_gateway_resource.refresh_token_resource.id
#   http_method = aws_api_gateway_method.refresh_token_get_method.http_method
#   status_code = "500"

#   response_models = {
#     "application/json" = "Empty"
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#     "method.response.header.Access-Control-Allow-Headers" = true
#   }
# }

resource "aws_api_gateway_integration_response" "refresh_token_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.refresh_token_resource.id
  http_method = aws_api_gateway_method.refresh_token_get_method.http_method
  status_code = aws_api_gateway_method_response.refresh_token_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method.refresh_token_get_method,
    aws_api_gateway_method_response.refresh_token_get_response,
    aws_api_gateway_integration.refresh_token_get_integration
  ]
}



#Permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw_invoke_refresh_token" {
  statement_id  = "AllowAPIGatewayInvokeRefreshToken"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.refresh_token_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.football_api.execution_arn}/*/*"
  depends_on    = [aws_lambda_function.refresh_token_function]
}

