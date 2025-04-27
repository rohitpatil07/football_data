variable "DYNAMODB_TABLE_NAME" {
  description = "Map for table name"
  type        = map(string)

  default = {
    "authentication" = "auth_users",
    "player_data"    = "players"
  }
}

variable "bucket_name" {
  description = "S3 bucket for triggering Lambda"
  type        = string
  default     = "lambda-trigger-bucket-demo-iabkacbefifopwqibfoqiefoq"
}