import json
import boto3
import bcrypt
import jwt
import os
from datetime import datetime, timedelta

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('auth_users')  # create this table manually for now

JWT_SECRET = os.getenv("JWT_SECRET", "your-secret")
JWT_ALGORITHM = "HS256"

def lambda_handler(event, context):
    method = event.get("httpMethod", "")
    
    if method == "OPTIONS":
        return respond(200, {"message": "CORS preflight handled"})

    body = json.loads(event.get("body"))
    action = body.get("action")  # 'signup' or 'login'
    username = body.get("username")
    password = body.get("password")

    if action == "signup":
        # Hash password
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

        # Save user with hashed password
        table.put_item(
            Item={
                "username": username,
                "password": hashed,
                "created_at": datetime.utcnow().isoformat()
            }
        )
        return respond(200, {"message": "Signup successful"})

    elif action == "login":
        # Fetch user from DynamoDB
        response = table.get_item(Key={"username": username})
        item = response.get("Item")

        if not item:
            return respond(401, {"error": "Invalid Credentials"})

        # Check hashed password
        if bcrypt.checkpw(password.encode('utf-8'), item["password"].encode('utf-8')):
            access_token = create_jwt_token(username, 15)  # expires in 15 mins
            refresh_token = create_jwt_token(username, 1440)  # valid for 1 day

            # Save refresh token ONLY in DynamoDB
            table.update_item(
                Key={"username": username},
                UpdateExpression="SET refresh_token = :r, last_login = :l",
                ExpressionAttributeValues={
                    ":r": refresh_token,
                    ":l": datetime.utcnow().isoformat()
                }
            )

            # Return only the access token
            return respond(200, {
                "access_token": access_token
            })
        else:
            return respond(401, {"error": "Incorrect password"})

    return respond(400, {"error": "Invalid action"})

def create_jwt_token(username, minutes):
    payload = {
        "sub": username,
        "exp": datetime.utcnow() + timedelta(minutes=minutes)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

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