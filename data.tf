data "aws_ami" "latest" {
    most_recent             = true
    provider                = aws.core 
    
    dynamic "filter" {
        for_each            = local.ami_filters

        content {
            name            = filter.value["key"]
            values          = filter.value["value"]
        }
    }
}