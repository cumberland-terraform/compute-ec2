module "platform" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-platform.git?ref=v1.0.19&depth=1"
  
  platform              = local.platform
}

module "kms" {
  count                 = local.conditions.provision_kms_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-core-security-kms.git?ref=v1.0.2&depth=1"

  kms                   = {
      alias_suffix      = "EC2"
  }
  platform              = var.platform
}

module "secret" {
  count                 = local.conditions.provision_ssh_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-core-security-sm.git?depth=1"

  secret                = {
    ssh_key             = {
      enabled           = true
      algorithm         = "RSA"
      bits              = 4096
    }
    suffix              = "EC2-PEM"
    kms_key             = local.kms_key
  }
  platform              = var.platform
}
