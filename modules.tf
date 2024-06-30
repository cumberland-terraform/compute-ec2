module "platform" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-platform.git"
  
  lookup                = var.platform
}

module "kms" {
  count                 = local.conditions.provision_kms_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-core-security-kms.git"

  key_config            = {
      alias_suffix      = "EC2"
  }
  platform              = var.platform
}
