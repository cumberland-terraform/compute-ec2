locals {
    ec2_tags            = {
                            Organization    = "mdthink"
                            Agency          = "mdh"
                            Project         = "aws-ec2-compute"
                            Owned           = "grant.moore@maryland.gov"
                            Service         = "ec2"
                        }
    kms_tags            = {
                            Organization    = "mdthink"
                            Team            = "mdh"
                            Project         = "aws-ec2-compute"
                            Owned           = "grant.moore@maryland.gov"
                            Service         = "kms"
                        }
    ssh_key_algorithm   = "RSA"
    ssh_key_bits        = 4096
    name_schema         = ""
    amis                = {
        RHEL            = "ami goes here"
        WINDOWS         = "ami goes here"
    }
    os_prefix           = "${path.module}/${lower(var.operating_system)}/user-data"
    userdata_path       = var.operating_system == "RHEL" ? "${local.os_prefix}.sh" : "${local.os_prefix}.bat"
    userdata_config     = var.operating_system == "RHEL" ? {
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