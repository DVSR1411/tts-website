import boto3
import json
dynamodb = boto3.client('dynamodb')
def lambda_handler(event, context):
    try:
        name = event['name']
        email = event['email']
        subject = event['subject']
        message = event['message']
        dynamodb.put_item(
            TableName='UserData',
            Item={'name': {'S': name}, 'email': {'S': email},'subject': {'S': subject},'message': {'S': message}}
        )
        return {
            'statusCode': 200,
            'body': json.dumps({"body": "Submitted successfully"})
        }
    except KeyError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({"body": f'Missing key: {str(e)}'})
        }