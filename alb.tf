# Certificate for ALB HTTPS Listener
variable "certificate_arn" {
  default = {
    prod    = "arn:aws:acm:us-east-1:860030201430:certificate/648a80aa-99e3-41b2-9a09-3c3ede1033a5"
  }
}

# ------------ #
# ALB Settings #
# ------------ #

resource "aws_lb" "main" {
  name            = "${var.project}-${var.stage}"
  internal        = false
  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.lb.id}"]

  access_logs {
    enabled = true
    bucket  = "${aws_s3_bucket.main.id}"
    prefix  = ""
  }

  tags {
    Project = "${var.project}-${var.stage}"
  }
}

# ALB HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    type             = "forward"
  }
}

# ALB HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.certificate_arn[var.stage]}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    type             = "forward"
  }
}
