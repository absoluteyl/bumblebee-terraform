resource "aws_s3_bucket" "main" {
  bucket        = "${var.project}-${var.stage}-${var.region[var.stage]}-${data.aws_caller_identity.current.account_id}"
  acl           = "private"
  force_destroy = true

  tags {
    Project = "${var.project}-${var.stage}"
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = "${aws_s3_bucket.main.id}"
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::127311923021:root"
      },
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.main.arn}/AWSLogs*"
    }
  ]
}
POLICY
}
