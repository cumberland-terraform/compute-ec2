data "aws_ami" "latest" {
    most_recent             = true
    owners                  = [ module.platform.aws.account_id ]
    dynamic "filter" {
        for_each            = local.ami_filters

        content {
            name            = filter.value["key"]
            values          = filter.value["value"]
        }
    }
}

data "aws_kms_key" "this" {
    count                   = var.kms.aws_managed ? 1 : 0

    key_id                  = local.ec2_defaults.aws_managed_key_alias
}