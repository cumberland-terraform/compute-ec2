provider "aws" {
    region           = "us-east-1"
    assume_role{
        role_arn     = "arn:aws:iam::798223307841:role/IMR-MDT-TERA-EC2"
    }
}

variables {
    platform                                = {
        aws_region                          = "US EAST 1"
        account                             = "ID ENGINEERING"
        acct_env                            = "DEVELOPMENT 1"
        agency                              = "MARYLAND TOTAL HUMAN-SERVICES INTEGRATED NETWORK"
        program                             = "MDTHINK SHARED PLATFORM"
        app                                 = "TERRAFORM ENTERPRISE"
        app_env                             = "PROOF OF CONCEPT"
        domain                              = "ENGINEERING"
        pca                                 = "FE110"
        owner                               = "MDT DevOps"
        subnet_type                         = "PUBLIC"
        availability_zones                  = [ "C01" ]
    }
    ec2                                     = {
        kms_key                             = {
            id                              = "b48b3d55-8104-48aa-a17b-425384fe4657"
        }
        operating_system                    = "RHEL7"
        tags                                = {
            purpose                         = "Mock Purpose"
            builder                         = "Mock Builder"
            primary_contact                 = "Mock Primary Contact"
            owner                           = "Mock Owner"
        }
    }
}

  
run "validate_ec2_ami"{
    providers = {
        aws = aws
    }
    command = plan
    assert {
        condition = aws_instance.instance.ami == "ami-08595d2c8a7d499c4"
        error_message = "Expected ami ID did not generate from provided parameters . Expected: ami-08595d2c8a7d499c4"
    }
    assert {
        condition = aws_security_group.remote_access_sg.vpc_id == "vpc-095012aae01b8551a"
        error_message = "Expected vpc_id did not generate from provided parameters . Expected: vpc-095012aae01b8551a"
    }
    assert {
        condition = aws_security_group_rule.remote_access_ingress.security_group_id == "sg-0b21fc66d0bea5c6b", "sg-0575308497bc077b2"
        error_message = "Expected security_group_id did not generate from provided parameters . Expected: sg-0b21fc66d0bea5c6b, sg-0575308497bc077b2"
    }
    assert {
        condition = aws_instance.instance.subnet_id  == "subnet-0fa5dcb643e244825"
        error_message = "Expected subnet_id did not generate from provided parameters . Expected: subnet-0fa5dcb643e244825"
    }
    assert {
        condition = aws_instance.instance.iam_instance_profile  == "IMR-IEG-NEWBUILD-ROLE"
        error_message = "Expected iam_instance_profile did not generate from provided parameters . Expected: IMR-IEG-NEWBUILD-ROLE"
    }
    assert {
        condition = local.tags.schedule == "never"
        error_message = "Expected schedule did not generate from provided parameters . Expected: never"
    }
   
    assert {
        condition = local.tags.owner == "AWS Devops Team"
        error_message = "Expected owner did not generate from provided parameters . Expected: AWS Devops Team"
    }
    assert {
        condition = local.tags.rhel_repo == "NA"
        error_message = "Expected rhel_repo did not generate from provided parameters . Expected: NA"
    }
    assert {
        condition = local.tags.PCA Code == "FE110"
        error_message = "Expected PCA Code did not generate from provided parameters . Expected: FE110"
    }
    assert {
        condition = local.tags.purpose == "Mock Purpose"
        error_message = "Expected  purpose  did not generate from provided parameters . Expected: Mock Purpose"
    }
    assert {
        condition = local.tags.Builder == "Mock Builder"
        error_message = "Expected Builder did not generate from provided parameters . Expected: Mock Builder"
    }
    
    assert {
        condition = local.tags.ec2.AutoBackup == "false"
        error_message = "Expected AutoBackup  did not generate from provided parameters . Expected:  false"
    }
    assert {
        condition = local.tags.primary_contact   == "Mock Primary Owner"
        error_message = "Expected  primary_contact did not generate from provided parameters . Expected: Mock Primary Owner "
    }
   
    
    assert {
        condition = aws_instance.instance.key_name  == "siegterad1e1c01"
        error_message = "Expected name did not generate from provided parameters . Expected: siegterad1e1c01 "
    }
    assert {
        condition = local.tags.OS   == "RHEL7"
        error_message = "Expected OS  did not generate from provided parameters . Expected: RHEL7 "
    }
   
   
   
   

}                                              
