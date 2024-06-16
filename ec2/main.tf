resource "aws_key_pair" "ssh_key" {
    count                                               = var.bastion_config.key_name == null ? 1 : 0

    key_name                                            = "${local.name_schema}_key"
    public_key                                          = tls_private_key.rsa[0].public_key_openssh
}


resource "tls_private_key" "rsa" {
    count                                               = var.bastion_config.key_name == null ? 1 : 0

    algorithm                                           = local.ssh_key_algorithm
    rsa_bits                                            = local.ssh_key_bits
}


resource "local_file" "tf-key" {
    count                                               = var.bastion_config.key_name == null ? 1 : 0

    content                                             = tls_private_key.rsa[0].private_key_pem
    filename                                            = "${path.root}/keys/${local.name_schema}_key"
}


resource "aws_security_group" "remote_access_sg" {
    name                                                = "${local.name_schema}-remote-access"
    description                                         = "${local.name_schema} security group"
    vpc_id                                              = var.vpc_config.id
    tags                                                = local.ec2_tags
}


resource "aws_security_group_rule" "remote_access_ingress" {
    description                                         = "Restrict access to IP whitelist and VPC CIDR block"
    type                                                = "ingress"
    from_port                                           = 0
    to_port                                             = 0
    protocol                                            = "-1"
    cidr_blocks                                         = concat(
                                                            var.source_ips,
                                                            [ data.aws_vpc.vpc.cidr_block ]
                                                        )
    security_group_id                                   = aws_security_group.remote_access_sg.id
} 


resource "aws_security_group_rule" "remote_access_egress" {
    description                                         = "Allow all outgoing traffic"
    type                                                = "egress"
    from_port                                           = 0
    to_port                                             = 0
    protocol                                            = "-1"
    cidr_blocks                                         = [
                                                            "0.0.0.0/0"
                                                        ]
    security_group_id                                   = aws_security_group.remote_access_sg.id
}


resource "aws_eip" "bastion_ip" {
    count                                               = var.bastion_config.public ? 1 : 0
    tags                                                = local.ec2_tags
}


resource "aws_eip_association" "eip_assoc" {
    count                                               = var.bastion_config.public ? 1 : 0

    instance_id                                         = aws_instance.bastion_host.id
    allocation_id                                       = aws_eip.bastion_ip[0].id
}

resource "aws_instance" "bastion_host" {
    #checkov:skip=CKV_AWS_88: "EC2 instance should not have public IP."
    #   NOTE: Security restricts traffic to IP whitelist.    
    ami                                                 = var.bastion_config.ami
    associate_public_ip_address                         = var.bastion_config.public
    ebs_optimized                                       = true
    key_name                                            = var.bastion_config.key_name == null ? aws_key_pair.ssh_key[0].key_name : var.bastion_config.key_name
    iam_instance_profile                                = var.bastion_config.instance_profile
    instance_type                                       = var.bastion_config.type
    monitoring                                          = true 
    subnet_id                                           = var.vpc_config.subnet_id
    tags                                                = merge(
                                                            local.ec2_tags,
                                                            {
                                                                Name                = "${local.name_schema}-host"
                                                            }
                                                        )
    user_data                                           = templatefile(
                                                            "${path.module}/user-data/user-data.sh",
                                                            {
                                                                AWS_DEFAULT_REGION  = "${data.aws_region.current.name}"
                                                                AWS_ACCOUNT_ID      = "${data.aws_caller_identity.current.account_id}"
                                                                SYS_ARCH            = "amd64"
                                                                OS                  = "linux"
                                                            }
                                                        )
    vpc_security_group_ids                              = concat(
                                                            [ aws_security_group.remote_access_sg.id ],
                                                            var.vpc_config.security_group_ids
                                                        )                                     

    metadata_options {
        http_endpoint                                   = "enabled"
        http_tokens                                     = "required"
    }

    root_block_device {
        encrypted                                       = true
    }
}







/**
resource "aws_instance" "instance" {
  ami                         = var.instance_config.ami
  instance_type               = var.instance_config.instance_type
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
*/
