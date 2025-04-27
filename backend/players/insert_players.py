import json
import csv 
import boto3
import os
import io

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ['TABLE_NAME']
    table = dynamodb.Table(table_name)

    s3 = boto3.client('s3')

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get the object from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        body = response['Body'].read().decode('utf-8')

        # Read the CSV data
        csv_reader = csv.DictReader(io.StringIO(body))
        
        for row in csv_reader:
            # Convert to DynamoDB item
            item = {k: str(v) for k, v in row.items()}
            table.put_item(Item=item)

        return {
            'statusCode': 200,
            'body': json.dumps('CSV data inserted into DynamoDB')      
        }