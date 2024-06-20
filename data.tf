data "aws_caller_identity" "current" {}


data "aws_region" "current" {}


data "aws_vpc" "vpc" {
    id                  = var.vpc_config.id
}

data "aws_ami" "latest" {
  most_recent           = true

    dynamic "filter" {
        for_each        = local.ami_filters

        content {
            name        = filter.value["key"]
            values      = filter.value["value"]
        }
    }
}