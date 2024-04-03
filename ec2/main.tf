module "lookup_data" {
  source           = "git::ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-lookups.git"
  lookupawsservice = "Elastic Compute Cloud"
  lookupagency     = var.agency
  lookupawsregion  = var.aws_region
  lookupprogram    = var.program
  lookupaccountenv = var.account_env
  lookupaccount    = var.account
}

resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = var.sg_ids
  user_data                   = var.user_data == "" ? "null" : var.user_data
  iam_instance_profile        = var.iam_instance_profile == "" ? null : var.iam_instance_profile
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address

  tags = merge(
    var.tags,
    {
      Name = "${join("-", [
        module.lookup_data.service_abbr,
        module.lookup_data.agency_oneletterkey,
        module.lookup_data.account_threeletterkey,
        module.lookup_data.program_abbr,
        module.lookup_data.region_twoletterkey,
        module.lookup_data.account_env_threeletterkey,
        var.suffix]
      )}",
      CreationDate = formatdate("YYYY-MM-DD", timestamp())
      Account      = var.account
      Environment  = var.account_env
      Agency       = var.agency
      Program      = var.program
      Region       = var.aws_region
      "PCA Code"   = var.pca_code
    }
  )
}
