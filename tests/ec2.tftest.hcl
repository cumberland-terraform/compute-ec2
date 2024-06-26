# valid_string_concat.tftest.hcl
provider "aws" {
    alias                   = "core"
    region                  = "us-east-1"
}

variables {
    ec2_config                              = {
        instance_profile                    = "IMR-IEG-NEWBUILD-ROLE"
        suffix                              = "TFE"
        operating_system                    = "RHEL7"
        provision_sg                        = false
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
            rhel_repo                       = "Monthly"
        }
        root_block_device                   = {
            volume_type                     = "gp3"
            volume_size                     = 50
        }
        ebs_block_devices                   = []
    }

    ec2_vpc_config                          = {
        availability_zone                   = "C"
        id                                  = "123456"
        subnet_id                           = "abcde"
        security_group_ids                  = [
            "hello_world"
        ]
    }
}

run "validate_tag" {

  command = plan

  assert {
    condition     = aws_instance.instance.tags.Owner == "AWS DevOps Team"
    error_message = "Owner Tag did not match input"
  }

}