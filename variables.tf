variable "platform" {
  description                     = "Platform metadata configuration object. See platform module (https://source.mdthink.maryland.gov/projects/ET/repos/mdt-eter-platform/browse) for detailed information about the permitted values for each field."
  type                            = object({
    aws_region                    = string 
    account                       = string
    acct_env                      = string
    agency                        = string
    program                       = string
    app                           = string
    app_env                       = string
    pca                           = string
    domain                        = string
    subnet_type                   = string
  })
}

variable "ec2" {
  description                     = "Configuration for the host environment. See EC2 module (https://source.mdthink.maryland.gov/projects/ET/repos/mdt-eter-core-compute-ec2/browse) for detailed information about the permitted values for each field."
  type = object({
    operating_system              = string
    availability_zone             = string
    tags                          = object({
      application                 = string
      builder                     = string
      primary_contact             = string
      owner                       = string
      purpose                     = string
      rhel_repo                   = optional(string, "NA")
      schedule                    = optional(string, "never")
      new_build                   = optional(bool, true)
      auto_backup                 = optional(bool, false) 
    })
    additional_security_group_ids = optional(list(string), null)
    root_block_device             = optional(object({
                                      volume_type   = string
                                      volume_size   = number
                                    }),{
                                      volume_type   = "gp3"
                                      volume_size   = 10
                                  })
    ebs_block_devices             = optional(list(object({
                                    device_name   = string
                                    volume_type   = string
                                    volume_size   = number
                                  })), [])
    instance_profile              = optional(string, null)
    type                          = optional(string, "t3.xlarge")
    ssh_key_name                  = optional(string, null)
    suffix                        = optional(string, "") 
    kms_key_id                    = optional(string, null)
    provision_sg                  = optional(bool, false)  
  })

  validation {
    condition                     = contains([
                                    "A", "B", "C", "D"
                                  ], var.ec2.availability_zone)
    error_message                 = "Valid values: (A, B, C, D)"
  }
  
  validation {
    condition                     = contains([
                                    "RHEL7",
                                    "RHEL8",
                                    "Windows2012R2",
                                    "Windows2016",
                                    "Windows2019",
                                    "Windows2022"
                                  ], var.ec2.operating_system)
    error_message                 = "Valid values: (RHEL7, RHEL8, Windows2012R2, Windows2016, Windows2019, Windows2022)"
  } 

  validation {
    condition                     = contains([
                                    "Monthly",
                                    "NA"
                                  ], var.ec2.tags.rhel_repo)
    error_message                 = "Valid values: (Monthly, NA)"
  } 

}
