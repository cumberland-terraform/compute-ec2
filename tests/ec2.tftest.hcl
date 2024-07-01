# valid_string_concat.tftest.hcl
provider "aws" {
    alias                   = "core"
    region                  = "us-east-1"
}

variables {
    ec2_config{
        tags {
            owner="AWS DevOps Team" 
        }
    }               
        
}

run "validate_tag" {

  command                                   = plan

  assert {
    condition                               = instance.tags.Owner == "AWS DevOps Team"
    error_message                           = "Owner Tag did not match input"
  }

}