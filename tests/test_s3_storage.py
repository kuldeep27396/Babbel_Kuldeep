import unittest
import boto3
import json
import time
from process_events import lambda_handler

class TestLambdaFunction(unittest.TestCase):

    def setUp(self):
        self.s3_client = boto3.client('s3')

    def test_lambda_function(self):
        kinesis_event = {
            "Records": [
                {
                    "kinesis": {
                        "data": json.dumps({
                            'event_uuid': '123456789',
                            'event_name': 'account:created',
                            'created_at': 1623862800
                        })
                    }
                }
            ]
        }

        response = lambda_handler(kinesis_event, None)

        time.sleep(5)
        bucket_name = 'your-s3-bucket-name'
        key = 'account/123456789.json'
        response = self.s3_client.get_object(Bucket=bucket_name, Key=key)
        stored_data = json.loads(response['Body'].read().decode('utf-8'))

        expected_data = {
            'event_uuid': '123456789',
            'event_name': 'account:created',
            'created_at': 1623862800,
            'created_datetime': '2021-06-16T12:00:00',
            'event_type': 'account',
            'event_subtype': 'created'
        }

        self.assertEqual(stored_data, expected_data)

if __name__ == '__main__':
    unittest.main()
