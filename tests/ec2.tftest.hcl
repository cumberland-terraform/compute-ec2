# valid_string_concat.tftest.hcl
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
        id                                  = data.aws_vpc.vpc.id
        subnet_id                           = data.aws_subnet.ec2_subnet.id
        security_group_ids                  = [
            data.aws_security_group.dmem_security_group.id,
            data.aws_security_group.rhel_security_group.id
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
    condition                               = instance.tags.Owner == "AWS DevOps Team"
    error_message                           = "Owner Tag did not match input"
  }

}
