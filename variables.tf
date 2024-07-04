variable "platform" {
  description                 = "Platform configuration metadata."
  type                        = object({
    core_aws_id               = string # TODO: look this up instead of pass ing
    tenant_aws_id             = string # TODO: look this up instead of passing in
    aws_region                = string 
    account                   = string
    acct_env                  = string
    agency                    = string
    program                   = string
    app                       = string
    app_env                   = string
    pca                       = string
    subnet_type               = string
    domain                    = string
  })
}

variable "ec2_config" {
  description                 = "Configuration for the host environment."
  type = object({
    instance_profile          = string
    operating_system          = string
    availability_zone         = string
    tags                      = object({
      application             = string
      builder                 = string
      contact                 = string
      rhel_repo               = string
      owner                   = string
      purpose                 = string
      schedule                = optional(string, "never")
      new_build               = optional(bool, true)
      auto_backup             = optional(bool, false) 
    })
    # `root_block_device`: configuration for root volume
    #     NOTE: this currently does nothing, since volumes are baked
    #     into the underlying AMI. 
    security_group_ids        = optional(list(string), null)
    root_block_device         = optional(
                                  object({
                                    volume_type   = string
                                    volume_size   = number
                                  }),
                                  {
                                    volume_type   = "gp3"
                                    volume_size   = 10
                                  })
    # `ebs_block_devices`: list of volumes to attach
    #     NOTE: this currently does nothing, since volumes are baked
    #     into the underlying AMI. 
    ebs_block_devices         = optional(list(
                                object({
                                  device_name   = string
                                  volume_type   = string
                                  volume_size   = number
                                })
                              ), [])
    type                      = optional(string, "t3.xlarge")
    ssh_key_name              = optional(string, null)
    suffix                    = optional(string, "") 
    kms_key_id                = optional(string, null)
    provision_sg              = optional(bool, false)
  })

  validation {
    condition                           = contains(
                                          [
                                            "RHEL7",
                                            "RHEL8",
                                            "Windows2012R2",
                                            "Windows2016",
                                            "Windows2019",
                                            "Windows2022"
                                          ], var.ec2_config.operating_system)
    error_message                       = "Valid values: (RHEL7, RHEL8, Windows2012R2, Windows2016, Windows2019, Windows2022)"
  } 

  validation {
    condition                           = contains(
                                          [
                                            "Monthly",
                                            "NA"
                                          ], var.ec2_config.tags.rhel_repo)
    error_message                       = "Valid values: (Monthly, NA)"
  } 

}
