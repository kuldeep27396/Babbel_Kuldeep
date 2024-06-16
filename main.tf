provider "aws" {
  region = "us-east-1"  # Update with your preferred AWS region
}

resource "aws_kinesis_stream" "event_stream" {
  name             = "EventStream"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}

resource "aws_lambda_function" "process_events_lambda" {
  filename      = "lambda_function.zip"
  function_name = "ProcessEventsLambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      S3_BUCKET_NAME = "your-s3-bucket-name"
    }
  }

  role = aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "s3_access_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::your-s3-bucket-name/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_lambda_event_source_mapping" "kinesis_event_source" {
  event_source_arn = aws_kinesis_stream.event_stream.arn
  function_name    = aws_lambda_function.process_events_lambda.function_name
  starting_position = "TRIM_HORIZON"  # Process records from the oldest available in the stream
}
