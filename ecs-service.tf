# Target Group
resource "aws_lb_target_group" "main" {
  name                 = "${var.project}-${var.stage}"
  protocol             = "HTTP"
  port                 = 80
  vpc_id               = "${module.vpc.vpc_id}"
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    protocol            = "HTTP"
    path                = "/robots.txt"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 10
    matcher             = "200-399"
  }

  tags {
    Project = "${var.project}-${var.stage}"
  }
}

# ALB Listener Rule for HTTP
resource "aws_lb_listener_rule" "http" {
  listener_arn = "${aws_lb_listener.http.arn}"
  priority     = "${var.priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.main.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.domain_name[var.stage]}"]
  }
}

# ALB Listener Rule for HTTPS
resource "aws_lb_listener_rule" "https" {
  listener_arn = "${aws_lb_listener.https.arn}"
  priority     = "${var.priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.main.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.domain_name[var.stage]}"]
  }
}

resource "aws_cloudwatch_log_group" "container-log" {
  name = "/${var.project}-${var.stage}/${var.project}/container-log"

  tags {
    Project = "${var.project}-${var.stage}"
  }
}

data "template_file" "main" {
  template = "${file("ecs-service-task-definitions.json")}"

  vars {
    project         = "${var.project}"
    env             = "${var.stage}"
    region          = "${var.region[var.stage]}"
    cluster_name    = "${aws_ecs_cluster.main.name}"
    service_name    = "${var.project}"
    app_revision    = "${var.app_revision[var.stage]}"
    app_cpu         = "${var.app_cpu[var.stage]}"
    app_memory      = "${var.app_memory[var.stage]}"
    sekrets_ps_name = "${var.sekrets_ps_name[var.stage]}"
  }
}

resource "aws_ecs_task_definition" "main" {
  requires_compatibilities = ["EC2"]
  family                   = "${var.project}-${var.stage}"
  task_role_arn            = "${aws_iam_role.ecs-task.arn}"
  execution_role_arn       = "${aws_iam_role.ecs-task.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.app_memory[var.stage]}"
  cpu                      = "${var.app_cpu[var.stage]}"
  container_definitions    = "${data.template_file.main.rendered}"
}

resource "aws_ecs_service" "main" {
  depends_on = [
    "aws_lb_listener_rule.http",
    "aws_lb_listener_rule.https",
  ]

  name                               = "${var.project}"
  cluster                            = "${aws_ecs_cluster.main.id}"
  launch_type                        = "EC2"
  task_definition                    = "${aws_ecs_task_definition.main.arn}"
  desired_count                      = "${var.desired_count[var.stage]}"
  deployment_minimum_healthy_percent = "${var.desired_count[var.stage] > 1 ? 50 : 100 }"
  deployment_maximum_percent         = "${var.desired_count[var.stage] > 1 ? 100 : 200 }"
  health_check_grace_period_seconds  = 5

  load_balancer {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    container_name   = "rails-app"
    container_port   = "80"
  }

  network_configuration {
    subnets         = ["${module.vpc.private_subnets}"]
    security_groups = ["${aws_security_group.ecs-service-server.id}"]
  }
}
