module "vpc" {
  # VPC
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.project}-${var.stage}"
  cidr                 = "${var.cidr[var.stage]}.0.0/16"
  enable_dns_hostnames = true

  # Public, Private, DB subnets
  azs                 = ["${var.azs[var.region[var.stage]]}"]
  private_subnets     = ["${var.cidr[var.stage]}.10.0/24", "${var.cidr[var.stage]}.11.0/24"]
  public_subnets      = ["${var.cidr[var.stage]}.20.0/24", "${var.cidr[var.stage]}.21.0/24"]
  database_subnets    = ["${var.cidr[var.stage]}.30.0/24", "${var.cidr[var.stage]}.31.0/24"]
  enable_nat_gateway  = true
  single_nat_gateway  = true

  # Tags
  vpc_tags = {
    Project = "${var.project}-${var.stage}"
  }
}

resource "aws_route" "default_nat_gateway" {
  route_table_id         = "${module.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${module.vpc.natgw_ids[0]}"
}
