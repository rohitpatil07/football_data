import jwt
import os

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

