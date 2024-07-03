provider "aws" {
    region                  = "us-east-1"

    assume_role {
        role_arn            = "arn:aws:iam::798223307841:role/IMR-MDT-TERA-EC2"
    }

}

provider "aws" {
    alias                   = "core"
    region                  = "us-east-1"
}


variables {
    ec2_config = {
        instance_profile                    = "IMR-IEG-NEWBUILD-ROLE"
        ssh_key_name                        = "MDTCoreUSEast1Virginia"
        operating_system                    = "RHEL7"
        type                                = "t3.xlarge"
        tags                                = {
            application                     = "Terraform Enterprise"
            builder                         = "Grant Moore - 2024-06-25"
            contact                         = "grant.moore@maryland.gov"
            auto_backup                     = false
            domain                          = "MDT.ENG"
            owner                           = "AWS DevOps Team"
            purpose                         = "Terraform Enterprise Test POC"
            new_build                       = true
            schedule                        = "never"
            rhel_repo                       = "NA"
            }
          }

    vpc_config                          = {
        availability_zone                   = "C"
        id                                  = "vpc-095012aae01b8551a"
        subnet_id                           = "N/A"
        security_group_ids                  = [
          "N/A"
          ]
        }
    platform                            = {
        core_aws_id                         = "545019462778"
        tenant_aws_id                       = "798223307841"
        aws_region                          = "US EAST 1"
        account                             = "ID ENGINEERING"
        acct_env                            = "DEVELOPMENT 1"
        agency                              = "MARYLAND TOTAL HUMAN-SERVICES INTEGRATED NETWORK"
        program                             = "MDTHINK SHARED PLATFORM"
        app                                 = "TERRAFORM ENTERPRISE"
        app_env                             = "DEVELOPMENT 1"
        pca                                 = "FE110"
        }
}


run "validate_tag" {

  command                                   = plan

  assert {
    condition                               = output.tags.Owner == "AWS DevOps Team"
    error_message                           = "Owner Tag did not match input"
  }

}
