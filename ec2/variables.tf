variable "agency" {
  description = "Agency name"
  type        = string
}

variable "account" {
  description = "The aws account"
  type        = string
}

variable "account_env" {
  description = "Environment at an account level"
  type        = string
}

variable "aws_region" {
  description = "The aws region"
  type        = string
}

variable "program" {
  description = "The program name"
  type        = string
}

variable "suffix" {
  description = "The suffix name for the ec2 instance"
  type        = string
}

variable "ami" {
  description = "The ami for the ec2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "ssh_key_name" {
  description = "The ssh_key_name for the ec2 instance"
  type        = string
}

variable "sg_ids" {
  description = "The security group ids for the ec2 instance"
  type        = list(string)
}

variable "user_data" {
  description = "The booststrap script for the ec2 instance"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "The instance profile for the ec2 instance"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The subnet Id for the ec2 instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "The public IP address for the ec2 instance"
  type        = bool
}

variable "pca_code" {
  description = "The PCA code for the instance tag"
  type        = string
}

variable "tags" {
  description = "Tags attached to the nat gateway"
  type        = map(string)
  default     = {}
}
