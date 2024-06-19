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

    # TODO: these are the AMI ids from the test account! 
    #       need to query caller account based on tags to retrieve ids!
    amis                = {
        RHEL            = "ami id goes here"
        WINDOWS         = "ami id goes here"
    }

    os_prefix           = "${path.module}/${lower(var.instance_config.operating_system)}/user-data"
    userdata_path       = var.instance_config.operating_system == "RHEL" ? "${local.os_prefix}.sh" : "${local.os_prefix}.bat"
    userdata_config     = var.instance_config.operating_system == "RHEL" ? {
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