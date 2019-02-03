# SG for All Traffic (Currently Not Used)
resource "aws_security_group" "all-traffic" {
  name_prefix = "${var.project}-${var.stage}-all-traffic-"
  vpc_id      = "${module.vpc.vpc_id}"

  # Inbound Rules
  # Allow Any Protocol from Any IPv4 Source
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Any Protocol from Any IPv6 Source
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  # Outbound Rules
  # Allow Any Protocol to Any IPv4 Destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Any Protocol to Any IPv6 Destination
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name    = "${var.project}-${var.stage}-all-traffic"
    Project = "${var.project}-${var.stage}"
  }
}

# SG for Load Balancers
resource "aws_security_group" "lb" {
  name_prefix = "${var.project}-${var.stage}-lb-"
  vpc_id      = "${module.vpc.vpc_id}"

  # Inbound Rules
  # Allow HTTP from Any IPv4 Source
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow HTTPS from Any IPv4 Source
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  # Allow Any Protocol to Any IPv4 Destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Any Protocol to Any IPv6 Destination
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name    = "${var.project}-${var.stage}-lb"
    Project = "${var.project}-${var.stage}"
  }
}

# SG for ECS Service Server
resource "aws_security_group" "ecs-service-server" {
  name_prefix = "${var.project}-${var.stage}-ecs-service-server-"
  vpc_id      = "${module.vpc.vpc_id}"

  # Inbound Rules
  # Allow HTTP from Any IPv4 Source
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow HTTP from Any IPv6 Source
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  # Outbound Rules
  # Allow Any Protocol to Any IPv4 Destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Any Protocol to Any IPv6 Destination
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name    = "${var.project}-${var.stage}-ecs-service-server"
    Project = "${var.project}-${var.stage}"
  }
}

# SG for ECS EC2 instances
resource "aws_security_group" "ecs-ec2" {
  name_prefix = "${var.project}-${var.stage}-ecs-ec2-"
  vpc_id      = "${module.vpc.vpc_id}"

  # Inbound Rules
  # Allow SSH from subspace private IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.sub_space_private_ip}"]
  }

  # Outbound Rules
  # Allow Any Protocol to Any IPv4 Destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Any Protocol to Any IPv6 Destination
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags {
    Name    = "${var.project}-${var.stage}-ecs-ec2"
    Project = "${var.project}-${var.stage}"
  }
}

# SG for RDS instances
resource "aws_security_group" "rds" {
  name_prefix = "${var.project}-${var.stage}-rds-"
  vpc_id      = "${module.vpc.vpc_id}"

  # Inbound Rules
  # Allow mySQL Connection from ECS Service and EC2
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.ecs-service-server.id}",
      "${aws_security_group.ecs-ec2.id}",
    ]
  }
  # Allow mySQL Connection from subspace private IP
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.sub_space_private_ip}"]
  }

  # Outbound Rules
  # Allow Any Protocol to Any IPv4 Destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.project}-${var.stage}-rds"
    Project = "${var.project}-${var.stage}"
  }
}
