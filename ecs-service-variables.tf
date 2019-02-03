variable "domain_name" {
  default = {
    prod    = "bumblebee.absoluteyl.me"
  }
}

variable "sekrets_ps_name" {
  default = {
    prod    = "/bumblebee/sekrets_key"
  }
}

variable "priority" {
  default = 80
}

variable "app_revision" {
  default = {
    prod    = "latest"
  }
}

variable "app_cpu" {
  default = {
    prod    = 1024
  }
}

variable "app_memory" {
  default = {
    prod    = 900
  }
}

variable "desired_count" {
  default = {
    prod    = 1
  }
}

variable "monitor" {
  default = {
    prod    = true
  }
}
