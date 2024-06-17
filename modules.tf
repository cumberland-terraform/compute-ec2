module "lookup_data" {
  source                = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-lookups.git"
  lookupawsservice      = "Elastic Compute Cloud"
  lookupagency          = var.platform.agency
  lookupawsregion       = var.platform.aws_region
  lookupprogram         = var.platform.program
  lookupaccountenv      = var.platform.account_env
  lookupaccount         = var.platform.account
}