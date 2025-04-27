resource "aws_lambda_function" "login_function" {
  filename      = "../backend/functions.zip"
  function_name = "login"
  role          = aws_iam_role.lambda_dynanodb_table_exec.arn
  handler       = "login.lambda_handler"
  runtime       = "python3.12"
  timeout       = 15
}

resource "aws_lambda_function" "logout_function" {
  filename      = "../backend/functions.zip"
  function_name = "logout"
  role          = aws_iam_role.lambda_dynanodb_table_exec.arn
  handler       = "logout.lambda_handler"
  runtime       = "python3.12"
  timeout       = 15
}

resource "aws_lambda_function" "refresh_token_function" {
  filename      = "../backend/functions.zip"
  function_name = "refresh_token"
  role          = aws_iam_role.lambda_dynanodb_table_exec.arn
  handler       = "refresh_token.lambda_handler"
  runtime       = "python3.12"
  timeout       = 15
}

resource "aws_lambda_function" "get_players_function" {
  filename      = "../backend/functions.zip"
  function_name = "get_players"
  role          = aws_iam_role.lambda_dynanodb_table_exec.arn
  handler       = "get_players.lambda_handler"
  runtime       = "python3.12"
  timeout       = 15
}

resource "aws_lambda_function" "verify_token_function" {
  filename      = "../backend/functions.zip"
  function_name = "verify_token"
  role          = aws_iam_role.lambda_dynanodb_table_exec.arn
  handler       = "verify_token.lambda_handler"
  runtime       = "python3.12"
  timeout       = 15
}

resource "aws_lambda_function" "insert_players_function" {
  filename      = "../backend/functions.zip"
  function_name = "insert_players"
  role          = aws_iam_role.lambda_dynanodb_table_exec.arn
  handler       = "insert_players.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.players_table.name
    }
  }

  depends_on = [aws_dynamodb_table.players_table, aws_iam_policy.lambda_dynamodb_exec_policy]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.insert_players_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.trigger_bucket.arn
}

