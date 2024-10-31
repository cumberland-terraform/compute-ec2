module "platform" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-platform.git?ref=v1.0.20&depth=1"
  
  platform              = local.platform
}

module "kms" {
  count                 = local.conditions.provision_kms_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-core-security-kms.git?ref=v1.0.2&depth=1"

  kms                   = local.kms
  platform              = var.platform
}

module "secret" {
  count                 = local.conditions.provision_ssh_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-core-security-sm.git?depth=1"

  secret                = local.secret
  platform              = var.platform
}

module "sg"        {
  count                   = local.conditions.provision_sg ? 1 : 0
  source                  = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-core-security-sg.git?depth=1"

  sg                      = local.sg
  platform                = local.platform
}