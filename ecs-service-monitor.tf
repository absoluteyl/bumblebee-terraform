resource "aws_cloudwatch_metric_alarm" "ecs-memory-utilization" {
  count = "${var.monitor[var.stage] ? 1 : 0}"

  alarm_name          = "${var.project}-${var.stage}-ecs-memory-utilization"
  metric_name         = "MemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 90
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.main.name}"
  }

  alarm_actions = ["${aws_sns_topic.email-notification.arn}"]
  ok_actions    = ["${aws_sns_topic.email-notification.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "tg-5XX" {
  count = "${var.monitor[var.stage] ? 1 : 0}"

  alarm_name          = "${var.project}-${var.stage}-tg-5XX"
  metric_name         = "HTTPCode_Target_5XX_Count"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"

  dimensions {
    LoadBalancer = "${aws_lb.main.arn_suffix}"
    TargetGroup  = "${aws_lb_target_group.main.arn_suffix}"
  }

  alarm_actions = ["${aws_sns_topic.email-notification.arn}"]
  ok_actions    = ["${aws_sns_topic.email-notification.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "healthy-host-count" {
  alarm_name          = "${var.project}-${var.stage}-healthy-host-count"
  metric_name         = "HealthyHostCount"
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"

  dimensions {
    LoadBalancer = "${aws_lb.main.arn_suffix}"
    TargetGroup  = "${aws_lb_target_group.main.arn_suffix}"
  }

  alarm_actions = ["${aws_sns_topic.email-notification.arn}"]
  ok_actions    = ["${aws_sns_topic.email-notification.arn}"]
}

resource "aws_route53_health_check" "main" {
  count = "${var.monitor[var.stage] ? 1 : 0}"

  type              = "HTTPS_STR_MATCH"
  fqdn              = "${var.domain_name[var.stage]}"
  port              = 443
  resource_path     = "/health/latency"
  request_interval  = "30"
  failure_threshold = "3"
  search_string     = "ok"

  tags = {
    Name    = "${var.project}-${var.stage}"
    Project = "${var.project}-${var.stage}"
  }
}

resource "aws_cloudwatch_metric_alarm" "route53-health-check" {
  count = "${var.monitor[var.stage] ? 1 : 0}"

  alarm_name          = "${var.project}-${var.stage}-route53-health-check"
  metric_name         = "HealthCheckPercentageHealthy"
  comparison_operator = "LessThanThreshold"
  threshold           = 70
  evaluation_periods  = 3
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/Route53"
  period              = 300
  statistic           = "Average"

  dimensions {
    HealthCheckId = "${aws_route53_health_check.main.id}"
  }

  alarm_actions = ["${aws_sns_topic.email-notification.arn}"]
  ok_actions    = ["${aws_sns_topic.email-notification.arn}"]
}
