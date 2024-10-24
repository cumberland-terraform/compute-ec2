variable "platform" {
  description                     = "Platform metadata configuration object. See platform module (https://source.mdthink.maryland.gov/projects/etm/repos/mdt-eter-platform/browse) for detailed information about the permitted values for each field."
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
    availability_zones            = list(string)
  })
}

variable "ec2" {
  description                     = "Configuration for the host environment. See EC2 module (https://source.mdthink.maryland.gov/projects/etm/repos/mdt-eter-core-compute-ec2/browse) for detailed information about the permitted values for each field."
  type = object({
    operating_system              = string
    tags                          = object({
      builder                     = string
      primary_contact             = string
      owner                       = string
      purpose                     = string
      rhel_repo                   = optional(string, "NA")
      schedule                    = optional(string, "never")
      new_build                   = optional(bool, true)
      auto_backup                 = optional(bool, false) 
    })
    root_block_device             = optional(object({
      volume_type                 = string
      volume_size                 = number
    }),{
        # <DEFAULT VALUES: `root_block_device`>
        volume_type               = "gp3"
        volume_size               = 10
        # </DEFAULT VALUES: `root_block_device`>
    })
    ebs_block_devices             = optional(list(object({
      device_name                 = string
      volume_type                 = string
      volume_size                 = number
    })), [])
    iam_instance_profile          = optional(string, null)
    type                          = optional(string, "t3.xlarge")
    ssh_key_name                  = optional(string, "MDTCoreUSEast1Virginia")
    vpc_security_group_ids        = optional(list(string), [])
    suffix                        = optional(string, "") 

    # NOTE: `private_ip` is *only* to lock in an IP in case of redeployment!
    #       this argument is not required!
    private_ip                    = optional(string, null)
    provision_sg                  = optional(bool, false)  
    user_data                     = optional(string, null)
    user_data_replace_on_change   = optional(string, true)

    kms_key                       = optional(object({
      aws_managed                 = optional(bool, true)
      id                          = optional(string, null)
      arn                         = optional(string, null)
      aias_arn                    = optional(string, null)
    }), null)
  })
  
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
