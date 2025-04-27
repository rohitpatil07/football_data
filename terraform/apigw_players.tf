#Players resource (/players)
resource "aws_api_gateway_resource" "players_resource" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  parent_id   = aws_api_gateway_rest_api.football_api.root_resource_id
  path_part   = "players"
}

#Options method for players resource
resource "aws_api_gateway_method" "players_options" {
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  resource_id   = aws_api_gateway_resource.players_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
#Response headers for players to allow cors
resource "aws_api_gateway_method_response" "players_options_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.players_resource.id
  http_method = aws_api_gateway_method.players_options.http_method
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
resource "aws_api_gateway_integration" "players_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.football_api.id
  resource_id             = aws_api_gateway_resource.players_resource.id
  http_method             = aws_api_gateway_method.players_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  depends_on = [aws_api_gateway_method_response.players_options_response]
}

#Integrate response headers with the players resource
resource "aws_api_gateway_integration_response" "player_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.players_resource.id
  http_method = aws_api_gateway_method.players_options.http_method
  status_code = aws_api_gateway_method_response.players_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization, X-Api-Key, X-Amz-Date, X-Amz-Security-Token'"
  }

  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.players_options_integration]
}

#GET Method for players resource
resource "aws_api_gateway_method" "players_get" {
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  resource_id   = aws_api_gateway_resource.players_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

#Integration for GET method
resource "aws_api_gateway_integration" "players_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.players_resource.id
  http_method = aws_api_gateway_method.players_get.http_method
  #its always post for proxy
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_players_function.invoke_arn

  depends_on = [aws_api_gateway_method_response.players_get_response]
}

#Integrate response headers with the players resource
resource "aws_api_gateway_method_response" "players_get_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.players_resource.id
  http_method = aws_api_gateway_method.players_get.http_method
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

resource "aws_api_gateway_integration_response" "players_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id
  resource_id = aws_api_gateway_resource.players_resource.id
  http_method = aws_api_gateway_method.players_get.http_method
  status_code = aws_api_gateway_method_response.players_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method_response.players_get_response, aws_api_gateway_method.players_get, aws_api_gateway_integration.players_get_integration]
}

#Permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw_invoke_get_players" {
  statement_id  = "AllowAPIGatewayInvokePlayers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_players_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.football_api.execution_arn}/*/*"
  depends_on    = [aws_lambda_function.get_players_function]
}
