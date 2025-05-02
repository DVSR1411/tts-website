import json
import os
from boto3 import client
from botocore.exceptions import ClientError
from datetime import datetime
def lambda_handler(event, context):
    polly = client('polly')
    s3 = client('s3')
    try:
        body = json.loads(event['body'])
        text = body['text']
        bucket_name = os.environ['bucket_name']
        region = os.environ['region']
        params = {
            'Text': text,
            'OutputFormat': 'mp3',
            'VoiceId': 'Salli'
        }
        response = polly.synthesize_speech(**params)
        key = f"audio-{int(datetime.now().timestamp())}.mp3"
        s3.put_object(
            Bucket=bucket_name,
            Key=key,
            Body=response['AudioStream'].read(),
            ContentType='audio/mpeg'
        )
        output = f"https://{bucket_name}.s3.ap-south-1.amazonaws.com/{key}"
        return {
            'statusCode': 200,
            'body': output
        }
    except ClientError:
        return {
            'statusCode': 500,
            'body': json.dumps('Internal Server error')
        }
