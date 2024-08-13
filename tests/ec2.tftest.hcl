provider "aws" {
    region           = "us-east-1"
    assume_role{
        role_arn     = "arn:aws:iam::798223307841:role/IMR-MDT-TERA-EC2"
    }
}

provider "aws" {
  # NOTE: when this is running through Jenkins, it automatically uses 
  #       the `jenkins-slave` IAM user from the Core account. Hence,
  #       the absence of an assume_role block.
  alias                     = "core"
  region                    = "us-east-1"
}

  variables {
    ec2 = {
        instance_profile                    = "IMR-IEG-NEWBUILD-ROLE"
        operating_system                    = "RHEL7"
        tags                                = {
            application                     = "Terraform Enterprise"
            builder                         = "Mock Builder"
            primary_contact                 = "Mock Primary Contact"
            auto_backup                     = false
            domain                          = "MDT.ENG"
            owner                           = "AWS DevOps Team"
            purpose                         = "Mock Purpose"
            new_build                       = true
            schedule                        = "never"
            rhel_repo                       = "NA"
            }
          }

    platform                            = {
        core_aws_id                         = "545019462778"
        tenant_aws_id                       = "798223307841"
        aws_region                          = "US EAST 1"
        account                             = "ID ENGINEERING"
        acct_env                            = "NON-PRODUCTION 1"
        agency                              = "MARYLAND TOTAL HUMAN-SERVICES INTEGRATED NETWORK"
        program                             = "MDTHINK SHARED PLATFORM"
        app                                 = "TERRAFORM ENTERPRISE"
        app_env                             = "NON PRODUCTION"
        domain                              = "ENGINEERING"
        pca                                 = "FE110"
        owner                               = "MDT DevOps"
        subnet_type                         = "PUBLIC"
        availability_zones                  = [ "C01" ]
    }

} 

run "validate_ec2_ami"{
     providers = {
        aws = aws
        aws.core = aws.core
    }
    command = plan
    assert {
        condition = data.aws_ami.latest.id == "ami-08595d2c8a7d499c4"
        error_message = "Expected ami ID did not generate from provided parameters . Expected: ami-08595d2c8a7d499c4"
    }
}

