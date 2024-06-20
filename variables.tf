variable "platform" {
  description                           = "Platform configuration for host deployment."
  type                                  = object({
    aws_id                              = string
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


variable "instance_config" {
  description                           = "Configuration for the host environment."
  type = object({
    instance_profile                    = string
    suffix                              = string
    operating_system                    = string
    type                                = optional(string, "t3.xlarge")
    key_name                            = optional(string, null)
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
      ], var.instance_config.operating_system)
    error_message                       = "Valid values: (RHEL7, RHEL8, Windows2012R2, Windows2016, Windows2019, Windows2022)."
  } 
}