resource "aws_iam_role" "logging" {
  name = "${local.name}-waf-stream-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "logging" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"CloudWatchAccess",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/kinesisfirehose/${local.name}-waf-stream:*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"KinesisAccess",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords"
      ],
      "Resource": [
        "${aws_kinesis_firehose_delivery_stream.main.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"S3Access",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.logging_bucket}",
        "arn:aws:s3:::${local.logging_bucket}/*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.logging.name
  policy_arn = aws_iam_policy.logging.arn
}

data "aws_iam_policy_document" "waf_reputation_list_parser" {
  count = var.reputationListsProtectionActivated ? 1 : 0
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

/*
The wrong arn is returned for IPsets
Expected: arn:aws:wafv2:us-east-1:{account_id}:global/ipset/{ip_set_id}/{ip_set_id}
Actual: arn:aws:wafv2:us-east-1:{account_id}:global/ipset/{ip_set_name}/{ip_set_id}
*/
resource "aws_iam_policy" "waf_reputation_list_parser" {
  count  = var.reputationListsProtectionActivated ? 1 : 0
  name   = "${var.app_name}-waf-reputation-list-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"CloudWatchLogs",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"WAFGetAndUpdateIPSet",
      "Action": [
          "wafv2:GetIPSet",
          "wafv2:UpdateIPSet"
      ],
      "Resource": [
          "${aws_wafv2_ip_set.IPReputationListsSetIPV4.arn}",
          "${aws_wafv2_ip_set.IPReputationListsSetIPV6.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"CloudWatchAccess",
      "Action": "cloudwatch:GetMetricStatistics",
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid":"DLQ",
      "Effect":"Allow",
      "Action":["sns:Publish","sqs:SendMessage"],
      "Resource":"${var.dead_letter_arn}"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "waf_reputation_list_parser" {
  count              = var.reputationListsProtectionActivated ? 1 : 0
  name               = "${var.app_name}-waf-reputation-list"
  assume_role_policy = data.aws_iam_policy_document.waf_reputation_list_parser[0].json
}

resource "aws_iam_role_policy_attachment" "waf_reputation_list_parser" {
  count      = var.reputationListsProtectionActivated ? 1 : 0
  role       = aws_iam_role.waf_reputation_list_parser[0].name
  policy_arn = aws_iam_policy.waf_reputation_list_parser[0].arn
}