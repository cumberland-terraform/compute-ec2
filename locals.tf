locals {
    tags                ={
      Name              = "${join("-", [
                            module.lookup_data.service_abbr,
                            module.lookup_data.agency_oneletterkey,
                            module.lookup_data.account_threeletterkey,
                            module.lookup_data.program_abbr,
                            module.lookup_data.region_twoletterkey,
                            module.lookup_data.account_env_threeletterkey,
                            var.instance_config.suffix]
                        )}",
      CreationDate      = formatdate("YYYY-MM-DD", timestamp())
      Account           = module.lookup_data.account_threeletterkey
      Environment       = module.lookup_data.env_oneletterkey
      Agency            = module.lookup_data.agency_oneletterkey
      Program           = module.lookup_data.program_key
      Region            = module.lookup_data.region_twoletterkey
      "PCA Code"        = var.platform.pca
    }
    prefix              = "${join("-", [
                            module.lookup_data.service_abbr,
                            module.lookup_data.agency_oneletterkey,
                            module.lookup_data.account_threeletterkey,
                            module.lookup_data.program_abbr]
                        )}"

    ssh_key_algorithm   = "RSA"
    ssh_key_bits        = 4096

    # These are extra filters that have to be added to the AMI data query to ensure the results
    #   returns are unique
    ami_filters                 = strcontains(var.instance_config.operating_system, "RHEL") ? [
        {
            "key"               = "tag:OS",
            "value"             = [ var.instance_config.operating_system ]
        },
        {
            "key"               = "tag:Application"
            "value"             =  [ "Base AMI" ]
        }
    ] : [
        {
            "key"               = "tag:OS",
            "value"             = [ var.instance_config.operating_system ]
        },
        {
            "key"               = "tag:Purpose"
            "value"             = [ "*Baseline*" ]
        }
    ]


    os_prefix           = "${path.module}/user-data/${lower(var.instance_config.operating_system)}/user-data"
    userdata_path       = strcontains(var.instance_config.operating_system, "RHEL") ? (
        # RHEL user-data EXTENSION
        "${path.module}/user-data/rhel/user-data.sh" 
    ) : (
        # WINDOWS user-data EXTENSION
        "${path.module}/user-data/windows/user-data.ps1" 
    )
    userdata_config     = strcontains(var.instance_config.operating_system, "RHEL") ? {
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