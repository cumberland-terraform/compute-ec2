locals {
    tags                        = merge({
        Name                    = module.platform.prefixes.compute.ec2.hostname
        Builder                 = var.ec2_config.tags.builder
        Owner                   = var.ec2_config.tags.owner
        Application             = var.ec2_config.tags.application
        Purpose                 = var.ec2_config.tags.purpose
        RhelRepo                = var.ec2_config.tags.rhel_repo
        Schedule                = var.ec2_config.tags.schedule
        AutoBackup              = var.ec2_config.tags.auto_backup
        PrimaryContact          = var.ec2_config.tags.contact
        NewBuild                = var.ec2_config.tags.new_build
        Domain                  = upper(var.ec2_config.tags.domain)
        OS                      = local.os
    }, module.platform.tags)

    ## EC2 PLATFORM DEFAULTS
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

    # These are extra filters that have to be added to the AMI data query to ensure the results
    #   returned are unique
    ami_filters                 = strcontains(var.ec2_config.operating_system, "RHEL") ? [
        {
            "key"               = "tag:OS",
            "value"             = [ var.ec2_config.operating_system ]
        },
        {
            "key"               = "tag:Application"
            "value"             =  [ "Base AMI" ] # sure would be nice if windows and rhel had consistent tags!
        }
    ] : [
        {
            "key"               = "tag:OS",
            "value"             = [ var.ec2_config.operating_system ]
        },
        {
            "key"               = "tag:Purpose"
            "value"             = [ "*Baseline*" ]
        }
    ]
}