# create authentication table
resource "aws_dynamodb_table" "auth_table" {
  name         = lookup(var.DYNAMODB_TABLE_NAME, "authentication", "auth_users")
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"

  attribute {
    name = "username"
    type = "S"
  }
}

# create table to hold player data
resource "aws_dynamodb_table" "players_table" {
  name         = lookup(var.DYNAMODB_TABLE_NAME, "player_data", "players")
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "name"

  attribute {
    name = "name"
    type = "S"
  }
}