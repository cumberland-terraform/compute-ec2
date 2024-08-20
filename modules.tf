module "platform" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-platform.git?ref=v1.0.8&depth=1"
  
  platform              = var.platform
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
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-core-security-sm.git"

  secret         = {
    secret_value        = tls_private_key.rsa[0].private_key_pem
    suffix              = "EC2-PEM"
    kms_key_id          = local.kms_key_id
  }
  platform              = var.platform
}
