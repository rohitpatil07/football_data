import json

def response(message,code,headers):
    return {
        "statuscode": code,
        "headers": headers,
        "body": json.dumps({"message": message})
    }

