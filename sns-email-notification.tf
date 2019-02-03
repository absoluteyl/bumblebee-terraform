resource "aws_sns_topic" "email-notification" {
  name = "${var.project}-${var.stage}-email-notification"
}
