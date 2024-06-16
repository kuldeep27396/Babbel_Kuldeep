import unittest
from unittest.mock import MagicMock
from datetime import datetime
import json

import boto3

from process_events import lambda_handler


class TestLambdaHandler(unittest.TestCase):

    def setUp(self):
        self.mock_s3_client = MagicMock()
        self.original_boto3_client = boto3.client
        boto3.client = MagicMock(return_value=self.mock_s3_client)

    def tearDown(self):
        boto3.client = self.original_boto3_client

    def test_lambda_handler(self):
        event_data = {
            'Records': [
                {
                    'kinesis': {
                        'data': json.dumps({
                            'event_uuid': '1234567890',
                            'event_name': 'example_event:subtype',
                            'created_at': 1633369261
                        })
                    }
                }
            ]
        }

        response = lambda_handler(event_data, None)

        self.assertEqual(response['statusCode'], 200)

        expected_message = 'Processed 1 records.'
        self.assertIn(expected_message, response['body'])

        self.mock_s3_client.put_object.assert_called_once()
        call_args = self.mock_s3_client.put_object.call_args
        put_object_args, put_object_kwargs = call_args
        self.assertEqual(put_object_kwargs['Bucket'], 'your-s3-bucket-name')
        self.assertTrue(put_object_kwargs['Key'].startswith('events/1234567890.json'))



if __name__ == '__main__':
    unittest.main()

