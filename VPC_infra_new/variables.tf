variable "vpc_cidr_block" {
  type = string
}

variable "region" {
  type = string
}

variable "public_subnets_cidr" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
    "us-east-1c" = "10.0.3.0/24"

  }
}

variable "private_subnets_cidr" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.11.0/24"
    "us-east-1b" = "10.0.12.0/24"
    "us-east-1c" = "10.0.13.0/24"

  }
}