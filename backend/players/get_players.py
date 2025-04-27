import json
import os
# import pymysql
import jwt
import boto3
# from utils.verify_token import verify_token  # Assuming you move this helper to utils/

# RDS connection details
# DB_HOST = os.getenv("DB_HOST")
# DB_USER = os.getenv("DB_USER")
# DB_PASSWORD = os.getenv("DB_PASSWORD")
# DB_NAME = os.getenv("DB_NAME")

JWT_SECRET = os.getenv("JWT_SECRET", "your-secret")
JWT_ALGORITHM = "HS256"

def verify_token(token):
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload  # Return payload if token is valid
    except jwt.ExpiredSignatureError:
        return None  # Token expired
    except jwt.InvalidTokenError:
        return None  # Invalid token

#dynamodb connection details
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('players')

def lambda_handler(event, context):
    # Step 1: Verify token
    auth_header = event.get("headers").get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return respond(401, {"error": "Authorization header missing"})

    token = auth_header.split(" ")[1]
    payload = verify_token(token)
    if not payload:
        return respond(401, {"error": "Invalid or expired token"})

    # Step 2: Connect to RDS and fetch players
    # try:
    #     conn = pymysql.connect(
    #         host=DB_HOST,
    #         user=DB_USER,
    #         password=DB_PASSWORD,
    #         db=DB_NAME,
    #         cursorclass=pymysql.cursors.DictCursor
    #     )
    #     with conn.cursor() as cursor:
    #         cursor.execute("SELECT name, club, nationality, goals, assists, market_value FROM players")
    #         results = cursor.fetchall()
    #     return respond(200, {"players": results})
    # except Exception as e:
    #     return respond(500, {"error": f"DB error: {str(e)}"})

    #Step 3: Or fetch data from dynamodb
    try:
        response = table.scan()
        items = response.get("Items", [])
        return respond(200, {"players": items})
    except Exception as e:
        return respond(500, {"error": f"DynamoDB error: {str(e)}"})

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
