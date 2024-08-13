provider "aws" {
    region                                  = "us-east-1"
    assume_role{
        role_arn                            = "arn:aws:iam::798223307841:role/IMR-MDT-TERA-EC2"
    }
}

provider "aws" {
  alias                                     = "core"
  region                                    = "us-east-1"
}


run "validate_ec2_ami"{
    providers                               = {
        aws                                 = aws
        aws.core                            = aws.core
    }
    command                                 = plan
    assert {
        condition                           = data.aws_ami.latest.id == "ami-08595d2c8a7d499c4"
        error_message                       = "Expected ami ID did not generate from provided parameters . Expected: ami-08595d2c8a7d499c4"
    }
}