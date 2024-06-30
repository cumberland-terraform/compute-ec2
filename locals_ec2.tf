locals {
    ## CONDITIONS
    # This is a map containing booleans that correspond to different 
    #       deployment configurations.
    conditions                  = {
        provision_ssh_key       = var.ec2_config.ssh_key_name == null
        provision_kms_key       = var.ec2_config.kms_key_id == null
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
    ## CALCULATED PROPERTIES
    # Variables that store local calculations.
    # TODO: `node` should be calculated or parameterized
    node                        = "01"
    os                          = strcontains(var.ec2_config.operating_system, "Windows") ? (
                                    "Windows"
                                ) : (
                                    var.ec2_config.operating_system
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
}