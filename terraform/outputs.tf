output "api_gw_dev_url" {
  value = "https://${aws_api_gateway_rest_api.football_api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.football_stage.stage_name}"
}