module "platform" {
  # META ARGUMENTS
  source                = "github.com/cumberland-terraform/platform.git"
  # PLATFORM ARGUMENTS
  platform              = local.platform
}

module "kms" {
  # META ARGUMENTS
  count                 = local.conditions.provision_kms_key ? 1 : 0
  source                = "github.com/cumberland-terraform/security-kms"
  # PLATFORM ARGUMENTS
  platform              = var.platform
  # MODULE ARGUMENTS
  kms                   = {
      alias_suffix      = var.suffix
  }
}

module "secret" {
  # META ARGUMENTS
  count                 = local.conditions.provision_ssh_key ? 1 : 0
  source                = "github.com/cumberland-terraform/security-sm.git"
  # PLATFORM ARGUMENTS
  platform              = var.platform
  # MODULE ARGUMENTS
  secret                = local.secret
}

module "sg"        {
  # META ARGUMENTS
  count                 = local.conditions.provision_sg ? 1 : 0
  source                = "github.com/cumberland-terraform/security-sg"
  # PLATFORM ARGUMENTS
  platform              = var.platform
  # MODULE ARGUMENTS
  sg                    = local.sg
}