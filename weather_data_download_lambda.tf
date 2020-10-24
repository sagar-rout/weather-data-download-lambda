terraform {
  required_providers {
    aws = {
      source    = "hashicorp/aws",
      "version" = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "iam_weather_data_download_lambda" {
  name = "iam_weather_data_download_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "weather_data_download" {
  function_name = "weather_data_download"
  handler       = "app.lambda_handler"
  role          = aws_iam_role.iam_weather_data_download_lambda.arn
  runtime       = "python3.8"
  timeout       = 30
  description   = "Download city weather data"

  filename = "weather_data_download.zip"

  source_code_hash = filebase64sha256("weather_data_download.zip")

  environment {
    variables = {
      OPEN_WEATHER_API        = "https://api.openweathermap.org/data/2.5/weather",
      OPEN_WEATHER_API_KEY  = "VALID_API_KEY",
      CITY_CODE  = "1271951"
    }
  }

}

resource "aws_cloudwatch_log_group" "weather_data_download_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.weather_data_download.function_name}"
  retention_in_days = 1 // I kept 1 because otherwise aws will charge 
}

resource "aws_iam_policy" "weather_data_download_logging_policy" {
  name        = "weather_data_download"
  path        = "/"
  description = "IAM policy for weather data download lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "weather_data_download_policy_attachment" {
  role       = aws_iam_role.iam_weather_data_download_lambda.name
  policy_arn = aws_iam_policy.weather_data_download_logging_policy.arn
}

resource "aws_cloudwatch_event_rule" "every_hour" {
  name                = "every_hour"
  description         = "Fires every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda_every_hour" {
  rule      = "${aws_cloudwatch_event_rule.every_hour.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.weather_data_download.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.weather_data_download.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_hour.arn}"
}