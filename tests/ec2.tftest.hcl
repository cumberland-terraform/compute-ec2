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
        core_aws_id                         = "545019462778"
        tenant_aws_id                       = "798223307841"
        aws_region                          = "US EAST 1"
        account                             = "ID ENGINEERING"
        acct_env                            = "NOT SURE"
        agency                              = "MARYLAND TOTAL HUMAN-SERVICES INTEGRATED NETWORK"
        program                             = "MDTHINK SHARED PLATFORM"
        app                                 = "PROOF OF CONCEPT"
        app_env                             = "DEVELOPMENT 1"
        pca                                 = "FE110"
        }
    }
    vpc_config = {
        type = {
        availability_zone                   = "C"
        id                                  = "MDT-IEG-E1-POC-APP"
        subnet_id                           ="MDT-IEG-E1-C01-APP-PUB" 
        security_group_ids                  = [
            "SG-SIEGE1-MDTENG-DMEM-EC2"
        ]
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