locals {
    ## CONDITIONS
    # This is a map containing booleans that correspond to different 
    #       deployment configurations.
    conditions                  = {
        provision_ssh_key       = var.ec2_config.ssh_key_name == null
        provision_kms_key       = var.ec2_config.kms_key_id == null
    }

    ## CALCULATED PROPERTIES
    # Variables that store local calculations.
    os                          = strcontains(var.ec2_config.operating_system, "Windows") ? (
                                    "Windows"
                                ) : (
                                    var.ec2_config.operating_system
                                )

    prefix                      = lower(
                                    join(
                                        "-", 
                                        [
                                            module.platform.service.abbr,
                                            module.platform.agency.oneletterkey,
                                            module.platform.account.threeletterkey,
                                            module.platform.program.abbr
                                        ]
                                    )
                                )
    tags                        = {
        Name                    = join(
                                    "",
                                    [
                                        module.platform.agency.oneletterkey,
                                        module.platform.account.threeletterkey,
                                        var.ec2_config.suffix,
                                        module.platform.program.key,
                                        module.platform.region.twoletterkey,
                                        module.platform.account_env.threeletterkey,
                                    ]
                                )
        CreationDate            = formatdate("YYYY-MM-DD", timestamp())
        Account                 = module.platform.account.threeletterkey
        Environment             = module.platform.account_env.fourletterkey
        Agency                  = module.platform.agency.abbr
        Program                 = module.platform.program.key
        Region                  = module.platform.region.twoletterkey
        "PCA Code"              = var.platform.pca
        Application             = var.ec2_config.tags.application
        AutoBackup              = var.ec2_config.tags.auto_backup
        Builder                 = var.ec2_config.tags.builder
        Owner                   = var.ec2_config.tags.owner
        OS                      = local.os
        Schedule                = var.ec2_config.tags.schedule
        PrimaryContact          = var.ec2_config.tags.contact
        NewBuild                = var.ec2_config.tags.new_build
        RhelRepo                = var.ec2_config.tags.rhel_repo
    }
    kms_key_id                  = local.conditions.provision_kms_key ? (
                                    module.kms[0].key.id
                                ) : (
                                    var.ec2_config.kms_key_id
                                )
    ssh_key_name                = local.conditions.provision_ssh_key ? (
                                    aws_key_pair.ssh_key[0].key_name 
                                ) : ( 
                                    var.ec2_config.ssh_key_name
                                ) 
    userdata_path               = strcontains(var.ec2_config.operating_system, "RHEL") ? (
        # RHEL ```user-data``` EXTENSION
        "${path.module}/user-data/rhel/user-data.sh" 
    ) : (
        # WINDOWS ```user-data``` EXTENSION
        "${path.module}/user-data/windows/user-data.ps1" 
    )
    userdata_config             = strcontains(var.ec2_config.operating_system, "RHEL") ? {
        # RHEL ```user-data``` CONFIGURATION
        AWS_DEFAULT_REGION      = "${data.aws_region.current.name}"
        AWS_ACCOUNT_ID          = "${data.aws_caller_identity.current.account_id}"
        SYS_ARCH                = "amd64"
        OS                      = "linux"
    } : {
        # WINDOWS ```user-data``` CONFIGURATION
        AWS_DEFAULT_REGION      = "${data.aws_region.current.name}"
        AWS_ACCOUNT_ID          = "${data.aws_caller_identity.current.account_id}"
    }

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