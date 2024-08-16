provider "aws" {
    region                      = "us-east-1"
    assume_role{
        role_arn                = "arn:aws:iam::798223307841:role/IMR-MDT-TERA-EC2"
    }
}

provider "aws" {
  alias                         = "core"
  region                        = "us-east-1"
}

variables {
    ec2 = {
        operating_system        = "RHEL7"
        tags                    = {
            builder             = "Mock Builder"
            primary_contact     = "Mock Primary Contact"
            owner               = "AWS DevOps Team"
            purpose             = "Mock Purpose"
        }
    }

    platform                    = { 
        aws_region              = "US EAST 1"
        account                 = "ID ENGINEERING"
        acct_env                = "NON-PRODUCTION 1"
        agency                  = "MARYLAND TOTAL HUMAN-SERVICES INTEGRATED NETWORK"
        program                 = "MDTHINK SHARED PLATFORM"
        app                     = "TERRAFORM ENTERPRISE"
        app_env                 = "NON PRODUCTION"
        domain                  = "ENGINEERING"
        pca                     = "FE110"
        subnet_type             = "PUBLIC"
        availability_zones      = [ "C01" ]
    }

} 

run "validate_ec2_ami"{
     providers                  = {
        aws                     = aws
        aws.core                = aws.core
    }
    command                     = plan
    assert {
        condition               = data.aws_ami.latest.id == "ami-08595d2c8a7d499c4"
        error_message           = "Expected ami ID did not generate from provided parameters . Expected: ami-08595d2c8a7d499c4"
    }
}

 run "validate_ec2_sg"{
      providers                 = {
        aws                     = aws
        aws.core                = aws.core
    }
    command                     = plan      
    assert {
        condition               = module.platform.network.security_groups.rhel == "sg-0b21fc66d0bea5c6b"
        error_message           = "Expected security_group_id did not generate from provided parameters . Expected: sg-0b21fc66d0bea5c6b"
    }
   assert {
        condition               = module.platform.network.security_groups.rhel == "sg-0575308497bc077b2"
        error_message           = "Expected security_group_id did not generate from provided parameters . Expected: sg-0575308497bc077b2"
    }
}

run "validate_ec2_iam_instance_profile"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan     
    assert {
        condition = local.iam_instance_profile == "IMR-IEG-NEWBUILD-ROLE"
        error_message = "Expected iam_instance_profile did not generate from provided parameters . Expected: IMR-IEG-NEWBUILD-ROLE"
    }
}

run "validate_ec2_schedule_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan  
    assert {
        condition = local.tags.schedule == "never"
        error_message = "Expected schedule did not generate from provided parameters . Expected: never"
    }
}

run "validate_ec2_owner_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan     
    assert {
        condition = local.tags.owner == "AWS Devops Team"
        error_message = "Expected owner did not generate from provided parameters . Expected: AWS Devops Team"
    }
}

run "validate_ec2_rhel_repo_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan
    assert {
        condition = local.tags.rhel_repo == "NA"
        error_message = "Expected rhel_repo did not generate from provided parameters . Expected: NA"
    }
}

run "validate_ec2_purpose_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan
    assert {
        condition = local.tags.purpose == "Mock Purpose"
        error_message = "Expected  purpose  did not generate from provided parameters . Expected: Mock Purpose"
    }
}

run "validate_ec2_builder_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan
    assert {
        condition = local.tags.Builder == "Mock Builder"
        error_message = "Expected Builder did not generate from provided parameters . Expected: Mock Builder"
    }
}

run "validate_ec2_autobackup_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan
    assert {
        condition = local.tags.ec2.AutoBackup == "false"
        error_message = "Expected AutoBackup  did not generate from provided parameters . Expected:  false"
    }
}

run "validate_ec2_primary_contact_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan
    assert {
        condition = local.tags.primary_contact   == "Mock Primary Owner"
        error_message = "Expected  primary_contact did not generate from provided parameters . Expected: Mock Primary Owner "
    }
}

run "validate_ec2_instance_key_name_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    command = plan  
    assert {
        condition = module.platform.prefixes.security.pem_key  == "siegterad1e1c01"
        error_message = "Expected name did not generate from provided parameters . Expected: siegterad1e1c01 "
    }
}

run "validate_ec2_instance_OS_tag"{
      providers = {
          aws = aws
          aws.core = aws.core
    }
    assert {
        condition = local.tags.OS   == "RHEL7"
        error_message = "Expected OS  did not generate from provided parameters . Expected: RHEL7 "
    }
}                                              