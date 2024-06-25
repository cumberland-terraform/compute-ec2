module "platform" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-platform.git"
  
  lookupawsservice      = "Elastic Compute Cloud"
  lookupagency          = var.platform.agency
  lookupawsregion       = var.platform.aws_region
  lookupprogram         = var.platform.program
  lookupaccountenv      = var.platform.env
  lookupaccount         = var.platform.account
}

module "kms" {
  count                 = local.conditions.provision_kms_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-core-security-kms.git"

  key_config            = {
      alias             = "${local.prefix}-ec2-key"
  }
  platform              = var.platform
}
