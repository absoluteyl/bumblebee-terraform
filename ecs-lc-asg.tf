data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "ecs-lc-asg-userdata" {
  template = "${file("ecs-lc-asg-userdata.sh")}"

  vars {
    cluster_name = "${aws_ecs_cluster.main.name}"
  }
}

# -------- #
# - Spot - #
# -------- #

resource "aws_launch_configuration" "ecs-spot" {
  name_prefix          = "${var.project}-${var.stage}-ecs-spot-lc-"
  image_id             = "${join("", data.aws_ami.ecs_ami.*.image_id)}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-ec2.name}"
  key_name             = "${var.key_name[var.stage]}"
  ebs_optimized        = false
  spot_price           = "${var.ecs_spot_price[var.stage]}"
  user_data            = "${data.template_file.ecs-lc-asg-userdata.rendered}"
  instance_type        = "${var.ecs_spot_instance_type[var.stage]}"
  security_groups      = ["${aws_security_group.ecs-ec2.id}"]

  root_block_device {
    volume_size           = "${var.root_block_volume_size[var.stage]}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdcz"
    volume_size           = 22
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-spot" {
  name                      = "${var.project}-${var.stage}-ecs-spot-asg"
  launch_configuration      = "${aws_launch_configuration.ecs-spot.name}"
  desired_capacity          = "${var.ecs_spot_asg_desired[var.stage]}"
  min_size                  = "${var.ecs_spot_asg_min[var.stage]}"
  max_size                  = "${var.ecs_spot_asg_max[var.stage]}"
  health_check_type         = "EC2"
  health_check_grace_period = 300
  availability_zones        = ["${var.azs[var.region[var.stage]]}"]
  vpc_zone_identifier       = ["${module.vpc.private_subnets}"]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.stage}-ecs"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Project"
    value               = "${var.project}-${var.stage}"
    propagate_at_launch = "true"
  }
}

# Spot Scaling Up Policy
resource "aws_autoscaling_policy" "ecs-spot-scaling-up" {
  name                   = "${var.project}-${var.stage}-ecs-spot-scaling-up"
  scaling_adjustment     = "${var.ecs_spot_scaling_up_adjustment[var.stage]}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs-spot.name}"
}

# ECS Spot Scaling Up Alarm
resource "aws_cloudwatch_metric_alarm" "ecs-spot-scaling-up" {
  alarm_name          = "${var.project}-${var.stage}-ecs-spot-scaling-up"
  metric_name         = "CPUReservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "${var.ecs_spot_scaling_up_threshold[var.stage]}"
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  alarm_description = "Cluster cpu reservation above ${var.ecs_spot_scaling_up_threshold[var.stage]}%"
  alarm_actions     = ["${aws_autoscaling_policy.ecs-spot-scaling-up.arn}"]
}

# Spot Scaling Down Policy
resource "aws_autoscaling_policy" "ecs-spot-scaling-down" {
  name                   = "${var.project}-${var.stage}-ecs-spot-scaling-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs-spot.name}"
}

# ECS Spot Scaling Down Alarm
resource "aws_cloudwatch_metric_alarm" "ecs-spot-scaling-down" {
  alarm_name          = "${var.project}-${var.stage}-ecs-spot-scaling-down"
  metric_name         = "CPUReservation"
  comparison_operator = "LessThanThreshold"
  threshold           = "${var.ecs_spot_scaling_down_threshold[var.stage]}"
  evaluation_periods  = 5
  treat_missing_data  = "notBreaching"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  alarm_description = "Cluster cpu reservation below ${var.ecs_spot_scaling_down_threshold[var.stage]}%"
  alarm_actions     = ["${aws_autoscaling_policy.ecs-spot-scaling-down.arn}"]
}
