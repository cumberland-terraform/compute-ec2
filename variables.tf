variable "platform" {
  description                     = "Platform metadata configuration object."
  type                            = object({
    client                        = string 
    environment                   = string
  })
}

variable "suffix" {
  description                     = "Naming suffix to apply to resources"
  type                            = string
}

variable "ec2" {
  description                     = "EC2 configuration object"
  type = object({
    operating_system              = string
    
    tags                          = optional(map(any), null)

    root_block_device             = optional(object({
      volume_type                 = string
      volume_size                 = number
    }),{
        volume_type               = "gp3"
        volume_size               = 10
    })

    ebs_block_devices             = optional(list(object({
      device_name                 = string
      volume_type                 = string
      volume_size                 = number
    })), [])

    iam_instance_profile          = optional(string, null)
    type                          = optional(string, "t3.xlarge")
    ssh_key_name                  = optional(string, "CumberlandCloudKey")
    vpc_security_group_ids        = optional(list(string), [])
    private_ip                    = optional(string, null)
    provision_sg                  = optional(bool, false)  
    user_data                     = optional(string, null)
    user_data_replace_on_change   = optional(string, true)
  })
}


variable "kms" {
  type                            = object({
    aws_managed                   = optional(bool, true)
    id                            = optional(string, null)
    arn                           = optional(string, null)
    alias_arn                     = optional(string, null)
  })
  default                         = {
    aws_managed                   = true
    id                            = null
    arn                           = null
    alias_arn                     = null
  }
}