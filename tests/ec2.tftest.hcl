# valid_string_concat.tftest.hcl
provider "aws" {
    alias                   = "core"
    region                  = "us-east-1"
}

variables {
    ec2_config = {
            tags = {
            owner = "AWS DevOps Team"
        }
    }
    platform = {
        type = {
            core_aws_id     = "TEST_VALUE"
            tenant_aws_id   = "TEST_VALUE"
            aws_region      = "TEST_VALUE" 
            account         = "TEST_VALUE"
            acct_env        = "TEST_VALUE"
            agency          = "TEST_VALUE"
            program         = "TEST_VALUE"
            app             = "TEST_VALUE"
            app_env         = "TEST_VALUE"
            pca             = "TEST_VALUE"
        }
    }
    vpc_config = {
        type = {
            id                                = "12341234"
            subnet_id                         = "TEST_VALUEs"
            availability_zone                 = "TEST_VALUE"
            security_group_ids                = ["TEST1", "TEST2"]
        }

    }                    
        
}

run "validate_tag" {

  command                                   = plan

  assert {
    condition                               = aws_instance.instance.tags.Owner == "AWS DevOps Team"
    error_message                           = "Owner Tag did not match input"
  }

}