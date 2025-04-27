import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('auth_users')

def lambda_handler(event, context):
    # Extract username from the request (could also come from token)
    body = json.loads(event["body"])
    username = body["username"]

    # Step 1: Check if the user exists
    response = table.get_item(Key={"username": username})
    item = response.get("Item")

    if not item:
        return respond(401, {"error": "User not found"})

    # Step 2: Clear the refresh token
    table.update_item(
        Key={"username": username},
        UpdateExpression="REMOVE refresh_token",
    )

    return respond(200, {"message": "Logged out successfully"})

def respond(status, body):
    return {
        "statusCode": status,
        "headers": {
        "Access-Control-Allow-Credentials": "true",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Api-Key",
        "Access-Control-Allow-Methods": "POST,OPTIONS",
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        },
        "body": json.dumps(body)
    }
