resource "aws_key_pair" "ssh_key" {
    count                        = local.conditions.provision_ssh_key ? 1 : 0

    key_name                     = local.secret.ssh_key.name
    public_key                   = module.secret[0].secret.public_key_openssh
}

resource "aws_instance" "instance" {
    ami                         = data.aws_ami.latest.id
    associate_public_ip_address = local.ec2_defaults.associate_public_ip_address
    ebs_optimized               = local.ec2_defaults.ebs_optimized
    key_name                    = local.ssh_key_name
    iam_instance_profile        = var.ec2.iam_instance_profile
    instance_type               = var.ec2.type
    monitoring                  = local.ec2_defaults.monitoring
    private_ip                  = var.ec2.private_ip
    # TODO: there could be multiple subnets in a given availability zone.
    #       the next line is simply taking the first one it finds. should 
    #       probably randomize the selection (i.e. choose a random number
    #       between 0 and (n-1), where n is `length(module.platform.subnets.id)`)
    subnet_id                   = module.platform.network.subnets.ids[0]
    tags                        = local.tags
    user_data                   = local.user_data
    user_data_replace_on_change = var.ec2.user_data_replace_on_change
    vpc_security_group_ids      = local.vpc_security_group_ids
    
    lifecycle {
        # NOTE: TF is interpretting the tag calculations as a modification everytime 
        #   a plan is run, so ignore until issue is resuled.
        ignore_changes          = [ tags, tags_all ]
    }

    metadata_options {
        http_endpoint           = "enabled"
        http_tokens             = "required"
    }

    root_block_device {
        encrypted               = local.ec2_defaults.encrypted
        kms_key_id              = local.kms_key.id
        volume_size             = var.ec2.root_block_device.volume_size
        volume_type             = var.ec2.root_block_device.volume_type
    }

    dynamic "ebs_block_device" {
        for_each                = { for index, device in var.ec2.ebs_block_devices:
                                        index => device }
                                        
        content {
            encrypted           = local.ec2_defaults.encrypted
            kms_key_id          = local.kms_key.id
            tags                = local.tags
            device_name         = ebs_block_device.value.device_name
            volume_size         = ebs_block_device.value.volume_size
            volume_type         = ebs_block_device.value.volume_type
        }
    }
}