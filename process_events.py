import json
import boto3
from datetime import datetime

s3_client = boto3.client('s3')


def lambda_handler(event, context):
    for record in event['Records']:
        # Parse incoming event
        event_data = json.loads(record['kinesis']['data'])

        # Transform data
        transformed_event = transform_event(event_data)

        # Store transformed event in S3
        store_in_s3(transformed_event)

    return {
        'statusCode': 200,
        'body': json.dumps('Processed {} records.'.format(len(event['Records'])))
    }


def transform_event(event_data):
    # Example transformation
    created_timestamp = event_data['created_at']
    event_type, event_subtype = event_data['event_name'].split(':')[:2]
    created_datetime = datetime.utcfromtimestamp(created_timestamp).isoformat()

    transformed_event = {
        'event_uuid': event_data['event_uuid'],
        'event_name': event_data['event_name'],
        'created_at': created_timestamp,
        'created_datetime': created_datetime,
        'event_type': event_type,
        'event_subtype': event_subtype,
        # Add other fields as needed
    }

    return transformed_event


def store_in_s3(data):
    bucket_name = 'your-s3-bucket-name'

