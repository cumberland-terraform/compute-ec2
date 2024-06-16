variable "platform" {
  description                           = "Platform configuration for host deployment."
  type                                  = object({
    aws_account                         = string
    aws_region                          = string 
    agency                              = string
    program                             = string
    env                                 = string
    pca                                 = string
  })
}

variable "source_ips" {
    description                         = "IPs to whitelist for remote ingress into the host. These IPs will be added to the security group around the host."
    type                                = list(string)
    sensitive                           = true
}


variable "vpc_config" {
    description                         = "VPC configuration for host deployment."
    type = object({
        id                              = string
        subnet_id                       = string
        security_group_ids              = list(string)
    })
    sensitive                           = true
}


variable "instance_config" {
    description                         = "Configuration for the host environment."
    type = object({
        instance_profile                = string
        key_name                        = string
        type                            = string
        public                          = bool

    })
    default = {
        instance_profile                = "AWSRoleforEC2"
        key_name                        = null
        type                            = "t3.xlarge"
        public                          = true
    }
}

variable "operating_system" {
  type                                  = string
  description                           = "some test value"

  validation {
    condition                           = contains(["RHEL", "WINDOWS"], var.operating_system)
    error_message                       = "Valid values: (RHEL, WINDOWS)."
  } 
}