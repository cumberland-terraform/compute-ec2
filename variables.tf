variable "platform" {
  description                           = "Platform configuration for host deployment."
  type                                  = object({
    core_aws_id                         = string
    tenant_aws_id                       = string
    aws_region                          = string 
    account                             = string
    agency                              = string
    program                             = string
    env                                 = string
    pca                                 = string
  })
}

variable "vpc_config" {
  description                           = "VPC configuration for host deployment."
  type = object({
      id                                = string
      subnet_id                         = string
      security_group_ids                = list(string)
  })
  sensitive                             = true
}


variable "ec2_config" {
  description                           = "Configuration for the host environment."
  type = object({
    instance_profile                    = string
    suffix                              = string
    operating_system                    = string
    ## The next four arguments are used to template EC2 tags
    # PRIMARY CONTACT: name of team member who is responsible for instance!
    contact                             = string
    # TODO: discover purpose of this tag
    schedule                            = string
    # TODO: discover purpose of this tag
    new_build                           = bool
    # TODO: discover purpose of this tag
    auto_backup                         = bool
    # `root_block_device`: configuration for root volume
    root_block_device                   = optional(
                                            object({
                                              volume_type   = string
                                              volume_size   = number
                                            }),
                                            {
                                              volume_type   = "gp3"
                                              volume_size   = 10
                                            }
                                        )
    # `ebs_block_devices`: list of volumes to attach
    ebs_block_devices                   = optional(
                                            list(
                                              object({
                                                device_name   = string
                                                volume_type   = string
                                                volume_size   = number
                                              })
                                            ), 
                                          [])
    type                                = optional(string, "t3.xlarge")
    ssh_key_name                        = optional(string, null)
    kms_key_id                          = optional(string, null)
    public                              = optional(bool, false)
    provision_sg                        = optional(bool, true)
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
    error_message                       = "Valid values: (RHEL7, RHEL8, Windows2012R2, Windows2016, Windows2019, Windows2022)."
  } 
}