resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.stage}"
}
