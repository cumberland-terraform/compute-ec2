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
    # NOTE: `is_rhel` is not the negation of `is_windows`, because MDThink also supports
    #           AMZN2 Linux distros.
    conditions                      = {
        provision_ssh_key           = var.ec2.ssh_key_name == null
        provision_kms_key           = var.ec2.kms_key == null
        provision_sg                = length(var.ec2.vpc_security_group_ids) == 0
        is_windows                  = strcontains(var.ec2.operating_system, "Windows")
        is_rhel7                    = strcontains(var.ec2.operating_system, "RHEL7")
        is_rhel8                    = strcontains(var.ec2.operating_system, "RHEL8")
        is_public                   = strcontains(upper(var.platform.subnet_type), "PUB")
        use_default_userdata        = var.ec2.user_data == null
        use_default_iam             = var.ec2.iam_instance_profile == null
    }
    # Derived Conditions (Conditions that depend on conditions, oh my!)
    derived                         = {
        is_rhel                     = local.conditions.is_rhel7 || local.conditions.is_rhel8 
    }
    ## CALCULATED PROPERTIES
    #   Variables that change based on deployment configuration. 
    kms_key                         = local.conditions.provision_kms_key ? (
                                        module.kms[0].key
                                    ) : !var.ec2.kms_key.aws_managed ? (
                                        var.ec2.kms_key
                                    ) :  merge({
                                        # NOTE: the different objects on either side of the ? ternary operator
                                        #       have to match type, so hacking the types together.
                                        aws_managed = true
                                        alias_arn   = join("/", [
                                            module.platform.aws.arn.kms.key,
                                            local.ec2_defaults.aws_managed_key_alias
                                        ])
                                    }, {
                                        id          = data.aws_kms_key.this[0].id
                                        arn         = data.aws_kms_key.this[0].arn
                                    })

    ssh_key_name                    = local.conditions.provision_ssh_key ? (
                                        aws_key_pair.ssh_key[0].key_name 
                                    ) : var.ec2.ssh_key_name

    vpc_security_group_ids          = local.conditions.is_windows ? concat([
                                    # TODO: figure out windows security groups
                                    ], var.ec2.additional_security_group_ids) : concat([
                                        module.platform.network.security_groups.dmem.id, 
                                        module.platform.network.security_groups.rhel.id 
                                    ], local.conditions.provision_sg ? [
                                        module.sg[0].security_group.id
                                    ] : var.ec2.additional_security_group_ids)

    user_data_path                  = local.conditions.is_rhel7 ? (
                                        "${path.module}/user-data/rhel7/user-data.sh" 
                                    ) : local.conditions.is_rhel8 ? ( 
                                        "${path.module}/user-data/rhel8/user-data.sh" 
                                    ) : "${path.module}/user-data/windows/user-data.ps1" 
    user_data_config                = local.conditions.is_rhel7 ? {
                                    
                                    } : local.conditions.is_rhel8 ? {

                                    }: {
                                        
                                    }
    user_data                       = local.conditions.use_default_userdata ? (
                                        templatefile(local.user_data_path, local.user_data_config)
                                    ) : var.ec2.user_data 

    os                              = local.conditions.is_windows ? (
                                        "Windows" # inconsistent tagging conventions between OSs.
                                    ) : var.ec2.operating_system

    iam_instance_profile            = local.conditions.use_default_iam ? (
                                        module.platform.prefixes.compute.ec2.profile
                                    ) : var.ec2.iam_instance_profile

    suffix                          = join("-", [
                                        module.platform.format.app.fourletterkey,
                                        "EC2"
                                    ])

    secret                          = {
        ssh_key                     = {
            enabled                 = true
            algorithm               = "RSA"
            bits                    = 4096
        }
        suffix                      = join("-", [
                                        local.suffix,
                                        "PEM"
                                    ])
        kms_key                     = local.kms_key
    }

    sg                              = {
        suffix                      = local.suffix
        description                 = "EC2 Security Group for ${module.platform.format.app.fourletterkey}"
        inbound_rules               = [{
            self                    = true
            description             = "Ingress from self"
            from_port               = 0
            to_port                 = 0
            protocol                = -1
        }]
    }

    kms                             = {
        alias_suffix                = local.suffix
    }

    tags                            = merge({
        Name                        = join("", [
                                        module.platform.prefixes.compute.ec2.hostname, 
                                        var.ec2.suffix
                                    ])
        Builder                     = var.ec2.tags.builder
        Owner                       = var.ec2.tags.owner
        Purpose                     = var.ec2.tags.purpose
        RhelRepo                    = var.ec2.tags.rhel_repo
        Schedule                    = var.ec2.tags.schedule
        AutoBackup                  = var.ec2.tags.auto_backup
        PrimaryContact              = var.ec2.tags.primary_contact
        NewBuild                    = var.ec2.tags.new_build
        OS                          = local.os
    }, module.platform.tags)


    platform                        = merge({

    }, var.platform)

    # These are extra filters that have to be added to the AMI data query to ensure the results
    #   returned are unique
    ami_filters                     = local.derived.is_rhel ? [
        {
            "key"                   = "tag:OS",
            "value"                 = [ var.ec2.operating_system ]
        },
        {
            "key"                   = "tag:Application"
            "value"                 =  [ "Base AMI" ] 
        }
    ] : [ 
        # It would be nice if Windows and RHEL had consistent tags for 
        #   identifying the baseline image...
        {
            "key"                   = "tag:OS",
            "value"                 = [ var.ec2.operating_system ]
        },
        {
            "key"                   = "tag:Purpose"
            "value"                 = [ "*Baseline*" ]
        }
    ]
}