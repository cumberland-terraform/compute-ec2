data "aws_ami" "latest" {
    most_recent             = true
    
    dynamic "filter" {
        for_each            = local.ami_filters

        content {
            name            = filter.value["key"]
            values          = filter.value["value"]
        }
    }
}

data "aws_kms_key" "this" {
    count                   = var.ec2.kms.aws_managed ? 1 : 0

    key_id                  = local.ec2_defaults.aws_managed_key_alias
}