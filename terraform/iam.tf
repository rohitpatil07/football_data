# create policy doc for 
# lambda to access dynamodb
# s3 access
data "aws_iam_policy_document" "lambda_dynamodb_exec_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.auth_table.arn,
      aws_dynamodb_table.players_table.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.trigger_bucket.arn}/*"
    ]
  }
}

#create the policy for table access
resource "aws_iam_policy" "lambda_dynamodb_exec_policy" {
  name   = "lambda_dynamodb_exec_policy"
  policy = data.aws_iam_policy_document.lambda_dynamodb_exec_policy_doc.json
}

#create the policy for lambda to assume role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create the lambda role
resource "aws_iam_role" "lambda_dynanodb_table_exec" {
  name               = "lambda_dynamodb_table_exec"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#attach the policy to lambda role
resource "aws_iam_policy_attachment" "lambda_attachment" {
  name = "lambda_dynamodb_table_policy_attachment"
  #   users      = []
  roles = [aws_iam_role.lambda_dynanodb_table_exec.name]
  #   groups     = [aws_iam_group.group.name]
  policy_arn = aws_iam_policy.lambda_dynamodb_exec_policy.arn
}

