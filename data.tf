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