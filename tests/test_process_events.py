import unittest
from process_events import transform_event

class TestEventTransformation(unittest.TestCase):

    def test_transform_event(self):
        event_data = {
            'event_uuid': '123456789',
            'event_name': 'account:created',
            'created_at': 1623862800
        }

        expected_transformed_event = {
            'event_uuid': '123456789',
            'event_name': 'account:created',
            'created_at': 1623862800,
            'created_datetime': '2021-06-16T12:00:00',
            'event_type': 'account',
            'event_subtype': 'created'
        }

        transformed_event = transform_event(event_data)

        self.assertEqual(transformed_event, expected_transformed_event)

if __name__ == '__main__':
    unittest.main()
