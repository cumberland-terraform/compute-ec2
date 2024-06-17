resource "aws_key_pair" "ssh_key" {
    count                        = var.bastion_config.key_name == null ? 1 : 0

    key_name                     = "${local.prefix}_key"
    public_key                   = tls_private_key.rsa[0].public_key_openssh
}


resource "tls_private_key" "rsa" {
    count                        = var.bastion_config.key_name == null ? 1 : 0

    algorithm                    = local.ssh_key_algorithm
    rsa_bits                     = local.ssh_key_bits
}


resource "local_file" "tf-key" {
    count                       = var.bastion_config.key_name == null ? 1 : 0

    content                     = tls_private_key.rsa[0].private_key_pem
    filename                    = "${path.root}/keys/${local.prefix}_key"
}


resource "aws_security_group" "remote_access_sg" {
    name                        = "${local.prefix}-remote-access"
    description                 = "${local.prefix} security group"
    vpc_id                      = var.vpc_config.id
    tags                        = local.tags
}


resource "aws_security_group_rule" "remote_access_ingress" {
    description                 = "Restrict access to IP whitelist and VPC CIDR block"
    type                        = "ingress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = concat(
                                    var.source_ips,
                                    [ data.aws_vpc.vpc.cidr_block ]
                                )
    security_group_id           = aws_security_group.remote_access_sg.id
} 


resource "aws_security_group_rule" "remote_access_egress" {
    description                 = "Allow all outgoing traffic"
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = [
                                    "0.0.0.0/0"
                                ]
    security_group_id           = aws_security_group.remote_access_sg.id
}


resource "aws_eip" "bastion_ip" {
    count                       = var.bastion_config.public ? 1 : 0
    tags                        = local.tags
}


resource "aws_eip_association" "eip_assoc" {
    count                       = var.bastion_config.public ? 1 : 0

    instance_id                 = aws_instance.bastion_host.id
    allocation_id               = aws_eip.bastion_ip[0].id
}

resource "aws_instance" "bastion_host" {

    ami                         = var.bastion_config.ami
    associate_public_ip_address = var.bastion_config.public
    ebs_optimized               = true
    key_name                    = var.bastion_config.key_name == null ? aws_key_pair.ssh_key[0].key_name : var.bastion_config.key_name
    iam_instance_profile        = var.bastion_config.instance_profile
    instance_type               = var.bastion_config.type
    monitoring                  = true 
    subnet_id                   = var.vpc_config.subnet_id
    tags                        = local.tags
    user_data                   = templatefile(
                                    local.userdata_path,
                                    local.userdata_config
                                )
    vpc_security_group_ids      = concat(
                                    [ aws_security_group.remote_access_sg.id ],
                                    var.vpc_config.security_group_ids
                                )                                     

    metadata_options {
        http_endpoint           = "enabled"
        http_tokens             = "required"
    }

    root_block_device {
        encrypted               = true
    }
}