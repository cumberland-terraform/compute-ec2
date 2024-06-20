data "aws_caller_identity" "current" {}


data "aws_region" "current" {}


data "aws_vpc" "vpc" {
    id                  = var.vpc_config.id
}

data "aws_ami" "latest" {
  most_recent      = true

  filter {
    name   = "tag:Version"
    values = [ var.instance_config.operating_system]
  }

}