locals {
  namespace = "logging"
}

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "fluentd_cloudwatch" {
  name       = "fluentd"
  repository = "${data.helm_repository.incubator.metadata.0.name}"
  namespace  = "${local.namespace}"
  chart      = "fluentd-cloudwatch"
  version    = "0.12.1"

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.create"
    value = true
  }
}

resource "aws_iam_policy" "cloudwatch-logs-worker-policy" {
  name        = format("%s-%s-cloudwatch-logs-worker-policy", var.product_name, var.environment)
  description = "cloudwatch-logs-worker-policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-role-arn-cloudwatch-logs-worker-policy" {
  role       = "${format("%s-%s-asg", var.product_name, var.environment)}"
  policy_arn = "${aws_iam_policy.cloudwatch-logs-worker-policy.arn}"
}
