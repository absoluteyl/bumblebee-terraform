variable "key_name" {
  default = {
    prod    = "bumblebee-201902031529"
  }
}

variable "root_block_volume_size" {
  default {
    prod    = 8
  }
}

variable "ecs_on_demain_instance_type" {
  default = {
    prod    = "t3.micro"
  }
}

variable "ecs_on_demain_asg_max" {
  default = {
    prod    = 0
  }
}

variable "ecs_on_demain_asg_desired" {
  default = {
    prod    = 0
  }
}

variable "ecs_on_demain_asg_min" {
  default = {
    prod    = 0
  }
}

variable "ecs_on_demain_scaling_up_threshold" {
  default = {
    prod    = 100
  }
}

variable "ecs_on_demain_scaling_down_threshold" {
  default = {
    prod    = 0
  }
}

variable "ecs_spot_instance_type" {
  default = {
    prod    = "t3.micro"
  }
}

variable "ecs_spot_asg_max" {
  default = {
    prod    = 2
  }
}

variable "ecs_spot_asg_desired" {
  default = {
    prod    = 1
  }
}

variable "ecs_spot_asg_min" {
  default = {
    prod    = 1
  }
}

variable "ecs_spot_price" {
  default = {
    prod    = 0.0045
  }
}

variable "ecs_spot_scaling_up_threshold" {
  default = {
    prod    = 100
  }
}

variable "ecs_spot_scaling_down_threshold" {
  default = {
    prod    = 0
  }
}

variable "ecs_spot_scaling_up_adjustment" {
  default = {
    prod    = 1
  }
}
