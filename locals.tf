locals {
    tags                ={
      Name              = "${join("-", [
                            module.lookup_data.service_abbr,
                            module.lookup_data.agency_oneletterkey,
                            module.lookup_data.account_threeletterkey,
                            module.lookup_data.program_abbr,
                            module.lookup_data.region_twoletterkey,
                            module.lookup_data.account_env_threeletterkey,
                            var.ec2_config.suffix]
                        )}",
      CreationDate      = formatdate("YYYY-MM-DD", timestamp())
      Account           = module.lookup_data.account_threeletterkey
      Environment       = module.lookup_data.account_env_fourletterkey
      Agency            = module.lookup_data.agency_oneletterkey
      Program           = module.lookup_data.program_key
      Region            = module.lookup_data.region_twoletterkey
      "PCA Code"        = var.platform.pca
      AutoBackup        = var.ec2_config.auto_backup
      Schedule          = var.ec2_config.schedule
      PrimaryContact    = var.ec2_config.contact
      NewBuild          = var.ec2_config.new_build
    }
    prefix              = lower(
                            "${join("-", [
                                module.lookup_data.service_abbr,
                                module.lookup_data.agency_oneletterkey,
                                module.lookup_data.account_threeletterkey,
                                module.lookup_data.program_abbr]
                            )}"
                        )

    ssh_key_algorithm   = "RSA"
    ssh_key_bits        = 4096

    conditions                      = {
        provision_ssh_key           = var.ec2_config.ssh_key_name == null
        provision_kms_key           = var.ec2_config.kms_key_id == null
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

    userdata_path       = strcontains(var.ec2_config.operating_system, "RHEL") ? (
        # RHEL user-data EXTENSION
        "${path.module}/user-data/rhel/user-data.sh" 
    ) : (
        # WINDOWS user-data EXTENSION
        "${path.module}/user-data/windows/user-data.ps1" 
    )
    userdata_config     = strcontains(var.ec2_config.operating_system, "RHEL") ? {
        # RHEL USERDATA CONFIGURATION
        AWS_DEFAULT_REGION  = "${data.aws_region.current.name}"
        AWS_ACCOUNT_ID      = "${data.aws_caller_identity.current.account_id}"
        SYS_ARCH            = "amd64"
        OS                  = "linux"
    } : {
        # WINDOWS USERDATA CONFIGURATION
        AWS_DEFAULT_REGION  = "${data.aws_region.current.name}"
        AWS_ACCOUNT_ID      = "${data.aws_caller_identity.current.account_id}"
    }
}