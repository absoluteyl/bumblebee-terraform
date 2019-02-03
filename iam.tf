# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs-task" {
  name = "${var.project}-${var.stage}-ecs-task-execution-role"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Existing Policy for ecs-task-execution-role
resource "aws_iam_role_policy_attachment" "ecs-task" {
  role       = "${aws_iam_role.ecs-task.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs-task" {
  statement {
    actions = [
      "cloudwatch:*",
      "ecr:*",
      "ecs:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "sns:Publish",
      "ssm:*",
    ]

    resources = [
      "*",
    ]
  }
}

# Inline Policy for ecs-task-execution-role
resource "aws_iam_role_policy" "ecs-task" {
  name   = "${aws_iam_role.ecs-task.name}-policy"
  role   = "${aws_iam_role.ecs-task.id}"
  policy = "${data.aws_iam_policy_document.ecs-task.json}"
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ecs-ec2" {
  name = "${var.project}-${var.stage}-ecs-ec2-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ssm.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs-ec2" {
  name = "${aws_iam_role.ecs-ec2.name}"
  role = "${aws_iam_role.ecs-ec2.name}"
}

# Existing Policy for ecs-ec2-role
resource "aws_iam_role_policy_attachment" "ecs-ec2-ssm" {
  role       = "${aws_iam_role.ecs-ec2.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy_document" "ecs-ec2" {
  statement {
    actions = [
      "cloudwatch:*",
      "ecr:*",
      "ecs:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "sns:Publish",
      "ssm:*",
    ]

    resources = [
      "*",
    ]
  }
}

# Inline Policy for ecs-ec2-role
resource "aws_iam_role_policy" "ecs-ec2" {
  name   = "${aws_iam_role.ecs-ec2.name}-policy"
  role   = "${aws_iam_role.ecs-ec2.id}"
  policy = "${data.aws_iam_policy_document.ecs-ec2.json}"
}
