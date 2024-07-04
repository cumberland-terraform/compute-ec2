module "platform" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-platform.git"
  
  platform              = var.platform
}

module "kms" {
  count                 = local.conditions.provision_kms_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-core-security-kms.git"

  key_config            = {
      alias_suffix      = "EC2"
  }
  platform              = var.platform
}

module "secret" {
  count                 = local.conditions.provision_ssh_key ? 1 : 0
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-core-security-sm.git"

  secret_config         = {
    secret_value        = tls_private_key.rsa[0].private_key_pem
    suffix              = "EC2-PEM"
    kms_key_id          = local.kms_key_id
  }
  platform              = var.platform
}