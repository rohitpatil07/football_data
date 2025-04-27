import json
import boto3
import jwt
import os
from datetime import datetime, timedelta

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('auth_users')

JWT_SECRET = os.getenv("JWT_SECRET", "your-secret")
JWT_ALGORITHM = "HS256"

def respond(status, body):
    return {
        "statusCode": status,
        "headers": {
        "Access-Control-Allow-Credentials": "true",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Api-Key",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        },
        "body": json.dumps(body)
    }

def lambda_handler(event, context):
    try:
        # Step 1: Get access token (even if expired)
        # event = json.loads(event)
        auth_header = event["headers"].get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return respond(401,"Auth header missing")

        access_token = auth_header.split(" ")[1]

        # Step 2: Decode without verifying expiry (just to extract username)
        payload = jwt.decode(access_token, JWT_SECRET, algorithms=[JWT_ALGORITHM], options={"verify_exp": False})
        username = payload.get("sub")

        if not username:
            return respond(401,"Invalid token payload")

        # Step 3: Check if user has a valid refresh token in DB
        response = table.get_item(Key={"username": username})
        item = response.get("Item")

        if not item or "refresh_token" not in item:
            return respond(401,"No active session. Please login again.")

        # Step 4: Issue new access token
        new_access_token = jwt.encode({
            "sub": username,
            "exp": datetime.utcnow() + timedelta(minutes=15)
        }, JWT_SECRET, algorithm=JWT_ALGORITHM)

        return respond(200,{
            "access_token": new_access_token
        })

    except jwt.InvalidTokenError:
        return respond(401,"Invalid token")

    except Exception as e:
        return respond(500,f"Something went wrong: {str(e)}")
