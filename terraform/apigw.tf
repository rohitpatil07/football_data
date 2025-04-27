#Create rest api
resource "aws_api_gateway_rest_api" "football_api" {
  name        = "football-app-api"
  description = "API Gateway for the Football App"
}

# API Deployment
resource "aws_api_gateway_deployment" "football_deployment" {
  rest_api_id = aws_api_gateway_rest_api.football_api.id

  depends_on = [
    aws_api_gateway_integration.login_integration,
    aws_api_gateway_integration.login_options_integration,
    aws_api_gateway_integration.players_get_integration,
    aws_api_gateway_integration.players_options_integration
  ]
}

#Stage
resource "aws_api_gateway_stage" "football_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.football_api.id
  deployment_id = aws_api_gateway_deployment.football_deployment.id

  depends_on = [
    aws_api_gateway_integration_response.login_options_integration_response,
    aws_api_gateway_integration_response.login_post_integration_response,
    aws_api_gateway_integration_response.player_options_integration_response,
    aws_api_gateway_integration_response.players_get_integration_response,
    aws_api_gateway_integration_response.refresh_token_options_integration_response,
    aws_api_gateway_integration_response.refresh_token_get_integration_response
  ]
}
