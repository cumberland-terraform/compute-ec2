locals {
    ## PLATFORM DEFAULTS
    #   These are platform specific configuration options. They should only need
    #       updated if the platform itself changes.
    ec2_defaults                = {
        ebs_optimized           = true
        encrypted               = true
        monitoring              = true
    }
    ssh_key_defaults            = {
        algorithm               = "RSA"
        bits                    = 4096
    }

    ## CONDITIONS
    #   Configuration object containing boolean calculations that correspond
    #       to different deployment configurations.
    # NOTE: `is_rhel` is not the negation of `is_windows`, because MDThink also supports
    #           AMZN2 Linux distros.
    conditions                  = {
        provision_ssh_key       = var.ec2.ssh_key_name == null
        provision_kms_key       = var.ec2.kms_key_id == null
        provision_sg            = var.ec2.provision_sg
        is_windows              = strcontains(var.ec2.operating_system, "Windows")
        is_rhel                 = strcontains(var.ec2.operating_system, "RHEL")
        is_public               = strcontains(upper(var.platform.subnet_type), "PUB")
    }

    ## CALCULATED PROPERTIES
    #   Variables that change based on deployment configuration. 
    kms_key_id                  = local.conditions.provision_kms_key ? (
                                    module.kms[0].key.id
                                ) : (
                                    var.ec2.kms_key_id
                                )
    ssh_key_name                = local.conditions.provision_ssh_key ? (
                                    aws_key_pair.ssh_key[0].key_name 
                                ) : ( 
                                    var.ec2.ssh_key_name
                                )
    baseline_vpc_sg_ids         = local.conditions.is_windows ? concat([
                                    # TODO: figure out windows security groups
                                    ], var.ec2.additional_security_group_ids) : concat([
                                        module.platform.network.security_groups.dmem.id, 
                                        module.platform.network.security_groups.rhel.id 
                                    ], var.ec2.security_group_ids)
    vpc_security_group_ids      = local.conditions.provision_sg ? concat(
                                    [ aws_security_group.remote_access_sg[0].id ],
                                    local.baseline_vpc_sg_ids
                                ) : local.baseline_vpc_sg_ids

    user_data_path              = local.conditions.is_rhel ? (
                                    # RHEL ```user-data``` EXTENSION
                                    "${path.module}/user-data/rhel/user-data.sh" 
                                ) : (
                                    # WINDOWS ```user-data``` EXTENSION
                                    "${path.module}/user-data/windows/user-data.ps1" 
                                )
    user_data_config            = local.conditions.is_rhel ? {
                                    # RHEL ```user-data``` CONFIGURATION
                                        # TODO: figure out what needs injected, if anything
                                } : {
                                    # WINDOWS ```user-data``` CONFIGURATION
                                        # TODO: figure out what needs injected, if anything
                                }
    user_data                   = templatefile(local.user_data_path, local.user_data_config)
    os                          = local.conditions.is_windows ? (
                                    "Windows" # inconsistent tagging conventions between OSs.
                                ) : (
                                    var.ec2.operating_system
                                )

    tags                        = merge({
        Name                    = "${module.platform.prefixes.compute.ec2.hostname}${var.ec2.suffix}"
        Builder                 = var.ec2.tags.builder
        Owner                   = var.ec2.tags.owner
        Application             = var.ec2.tags.application
        Purpose                 = var.ec2.tags.purpose
        RhelRepo                = var.ec2.tags.rhel_repo
        Schedule                = var.ec2.tags.schedule
        AutoBackup              = var.ec2.tags.auto_backup
        PrimaryContact          = var.ec2.tags.primary_contact
        NewBuild                = var.ec2.tags.new_build
        OS                      = local.os
    }, module.platform.tags)

    # These are extra filters that have to be added to the AMI data query to ensure the results
    #   returned are unique
    ami_filters                 = local.conditions.is_rhel ? [
        {
            "key"               = "tag:OS",
            "value"             = [ var.ec2.operating_system ]
        },
        {
            "key"               = "tag:Application"
            "value"             =  [ "Base AMI" ] # sure would be nice if windows and rhel had consistent tags!
        }
    ] : [
        {
            "key"               = "tag:OS",
            "value"             = [ var.ec2.operating_system ]
        },
        {
            "key"               = "tag:Purpose"
            "value"             = [ "*Baseline*" ]
        }
    ]
}