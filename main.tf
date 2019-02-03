variable "project" {
  default = "bumblebee"
}

variable "stage" {}

variable "region" {
  default = {
    prod    = "us-east-1"
  }
}

variable "azs" {
  default = {
    us-east-1 = ["us-east-1a", "us-east-1c"]
  }
}

# for VPC
variable "cidr" {
  default = {
    prod    = "10.1"
  }
}

variable "sub_space_private_ip" {
  default = "10.1.20.167/32"
}
locals {
  nat_public_ips = ["${module.vpc.nat_public_ips[0]}/32"]
}

provider "aws" {
  region = "${var.region[var.stage]}"
}

data "aws_caller_identity" "current" {}
