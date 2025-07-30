locals {
    ## PLATFORM DEFAULTS
    #   These are platform specific configuration options. They should only need
    #       updated if the platform itself changes.
    ec2_defaults                    = {
        associate_public_ip_address = false
        ebs_optimized               = true
        encrypted                   = true
        monitoring                  = true
        aws_managed_key_alias       = "alias/aws/ebs"
    }
    ssh_key_defaults                = {
        algorithm                   = "RSA"
        bits                        = 4096
    }

    ## CONDITIONS
    #   Configuration object containing boolean calculations that correspond
    #       to different deployment configurations.
    conditions                      = {
        provision_ssh_key           = var.ec2.ssh_key_name == null
        provision_kms_key           = var.kms == null
        provision_sg                = length(var.ec2.vpc_security_group_ids) == 0
        use_default_userdata        = var.ec2.user_data == null
    }
    
    ## CALCULATED PROPERTIES
    #   Variables that change based on deployment configuration. 
    kms                             = local.conditions.provision_kms_key ? (
                                        module.kms[0].key
                                    ) : !var.kms.aws_managed ? (
                                        var.kms
                                    ) : {
                                        aws_managed = true
                                        alias_arn   = join("/", [
                                            module.platform.aws.arn.kms.key,
                                            local.ec2_defaults.aws_managed_key_alias
                                        ])
                                        id          = data.aws_kms_key.this[0].id
                                        arn         = data.aws_kms_key.this[0].arn
                                    }

    ssh_key_name                    = local.conditions.provision_ssh_key ? (
                                        aws_key_pair.ssh_key[0].key_name 
                                    ) : var.ec2.ssh_key_name

    vpc_security_group_ids          = local.conditions.provision_sg ? [
                                        module.sg[0].security_group.id
                                    ] : var.ec2.vpc_security_group_ids

    user_data_path                  =  local.conditions.use_default_userdata ? (
                                        "${path.module}/user-data/user-data.sh" 
                                    ) : var.ec2.user_data
 
    user_data_config                = {
                                        # TODO: any variables in user-data get
                                        # defined and injected here
                                    }
    user_data                       = local.conditions.use_default_userdata ? (
                                        templatefile(local.user_data_path, local.user_data_config)
                                    ) : var.ec2.user_data 

    name                            = upper(join("-", [module.platform.prefix,
                                        var.suffix
                                    ]))

    secret                          = {
        ssh_key                     = {
            enabled                 = true
            algorithm               = "RSA"
            bits                    = 4096
            name                    = upper(join("-", [
                                        local.name,
                                        "PEM"
                                    ]))
        }
        suffix                      = upper(join("-", [
                                        "PEM",
                                        var.suffix
                                    ]))
        kms_key                     = local.kms
    }

    sg                              = {
        suffix                      = join("-", [
                                        local.name,
                                        "SG"
                                    ])
        description                 = "EC2 Security Group for ${local.name}"
        inbound_rules               = [{
            self                    = true
            description             = "Ingress from self"
            from_port               = 0
            to_port                 = 0
            protocol                = -1
        }]
    }

    tags                            = merge({
        Name                        = local.name
    }, module.platform.tags)


    platform                        = merge({
        
    }, var.platform)

    ami_filters                     = [ {
        key                         = "tag:OS",
        value                       = [ var.ec2.operating_system ]
    }]
}