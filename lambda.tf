resource "aws_cloudwatch_log_group" "kubernetes_log_group" {
  name              = "kubernetes"
  retention_in_days = 14
}

resource "aws_iam_role" "lambda_elasticsearch_execution_role" {
  name = format("%s-%s-lambda-basic-execution-role", var.product_name, var.environment)

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

resource "aws_iam_role_policy" "lambda_elasticsearch_execution_policy" {
  name   = "lambda_elasticsearch_execution_policy"
  role   = "${aws_iam_role.lambda_elasticsearch_execution_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "es:ESHttpPost",
      "Resource": "arn:aws:es:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_elasticsearch_execution_policy_vpc_access" {
  role       = "${aws_iam_role.lambda_elasticsearch_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/LogToElasticsearch/"
  output_path = "${path.module}/.terraform/archive_files/LogToElasticsearch.zip"
}

resource "aws_lambda_function" "cwl_stream_lambda" {
  filename         = "${data.archive_file.lambda_code.output_path}"
  source_code_hash = "${filebase64sha256("${data.archive_file.lambda_code.output_path}")}"
  function_name    = "LogsToElasticsearch"
  handler          = "index.handler"
  role             = "${aws_iam_role.lambda_elasticsearch_execution_role.arn}"
  runtime          = "nodejs10.x"

  vpc_config {
    security_group_ids = [
      module.elasticsearch_logs.security_group_id
    ]
    subnet_ids = [
      var.data_subnet_ids.0,
    ]
  }

  environment {
    variables = {
      es_endpoint = "${module.elasticsearch_logs.domain_endpoint}"
    }
  }
}

resource "aws_lambda_permission" "cloudwatch_allow" {
  statement_id  = "cloudwatch_allow"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cwl_stream_lambda.arn}"
  principal     = "logs.eu-central-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.kubernetes_log_group.arn}"
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_to_es" {
  depends_on      = ["aws_lambda_permission.cloudwatch_allow"]
  name            = "cloudwatch_logs_to_elasticsearch"
  log_group_name  = "${aws_cloudwatch_log_group.kubernetes_log_group.name}"
  filter_pattern  = ""
  destination_arn = "${aws_lambda_function.cwl_stream_lambda.arn}"
}
