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
      Account           = var.platform.account
      Environment       = var.platform.env
      Agency            = var.platform.agency
      Program           = var.platform.program
      Region            = var.platform.aws_region
      "PCA Code"        = var.platform.pca
    }

    ssh_key_algorithm   = "RSA"
    ssh_key_bits        = 4096

    prefix              = "${join("-", [
                            module.lookup_data.service_abbr,
                            module.lookup_data.agency_oneletterkey,
                            module.lookup_data.account_threeletterkey,
                            module.lookup_data.program_abbr]
                        )}"

    # These are extra filters that have to be added to the AMI data query to ensure the results
    #   returns are unique.
    # TODO: this is the ideal way of querying the AMI ids. The idea is we should be able to pull
    #       AMI from target account using tags. However, the current build process builds AMI in
    #       the CORE account and then shares them with child accounts. 
    ami_filters                     = strcontains(var.instance_config.operating_system, "RHEL") ? [
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