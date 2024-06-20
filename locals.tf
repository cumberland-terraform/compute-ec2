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

    os_prefix           = "${path.module}/user-data/${lower(var.instance_config.operating_system)}/user-data"
    userdata_path       = strcontains(var.instance_config.operating_system, "RHEL") ? (
        # RHEL user-data EXTENSION
        "${local.os_prefix}.sh" 
    ) : (
        # WINDOWS user-data EXTENSION
        "${local.os_prefix}.ps1"
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