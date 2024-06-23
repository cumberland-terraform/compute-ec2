resource "aws_key_pair" "ssh_key" {
    count                        = local.conditions.provision_ssh_key ? 1 : 0

    key_name                     = "${local.prefix}_key"
    public_key                   = tls_private_key.rsa[0].public_key_openssh
}


resource "tls_private_key" "rsa" {
    count                        = local.conditions.provision_ssh_key ? 1 : 0

    algorithm                    = local.ssh_key_algorithm
    rsa_bits                     = local.ssh_key_bits
}


resource "local_file" "tf-key" {
    count                       = local.conditions.provision_ssh_key ? 1 : 0

    content                     = tls_private_key.rsa[0].private_key_pem
    filename                    = "${path.root}/keys/${local.prefix}_key"
}


resource "aws_security_group" "remote_access_sg" {
    count                       = var.ec2_config.provision_sg ? 1 : 0

    name                        = "${local.prefix}-remote-access"
    description                 = "${local.prefix} security group"
    vpc_id                      = var.vpc_config.id
    tags                        = local.tags
}


resource "aws_security_group_rule" "remote_access_ingress" {
    count                       = var.ec2_config.provision_sg ? 1 : 0

    description                 = "Restrict access to VPC CIDR block"
    type                        = "ingress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = [ data.aws_vpc.vpc.cidr_block ]
    security_group_id           = aws_security_group.remote_access_sg[count.index].id
} 


resource "aws_security_group_rule" "remote_access_egress" {
    count                       = var.ec2_config.provision_sg ? 1 : 0

    description                 = "Allow all outgoing traffic"
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = [ "0.0.0.0/0" ]
    security_group_id           = aws_security_group.remote_access_sg[count.index].id
}


resource "aws_eip" "bastion_ip" {
    count                       = var.ec2_config.public ? 1 : 0
    tags                        = local.tags
}


resource "aws_eip_association" "eip_assoc" {
    count                       = var.ec2_config.public ? 1 : 0

    instance_id                 = aws_instance.instance.id
    allocation_id               = aws_eip.bastion_ip[0].id
}

resource "aws_instance" "instance" {
    ami                         = data.aws_ami.latest.id
    associate_public_ip_address = var.ec2_config.public
    ebs_optimized               = true
    key_name                    = local.conditions.provision_ssh_key ? (
                                    aws_key_pair.ssh_key[0].key_name 
                                ) : ( 
                                    var.ec2_config.ssh_key_name
                                )
    iam_instance_profile        = var.ec2_config.instance_profile
    instance_type               = var.ec2_config.type
    monitoring                  = true 
    subnet_id                   = var.vpc_config.subnet_id
    tags                        = local.tags
    user_data                   = templatefile(
                                    local.userdata_path,
                                    local.userdata_config
                                )
    vpc_security_group_ids      = var.ec2_config.provision_sg ? concat(
                                    [ aws_security_group.remote_access_sg[0].id ],
                                    var.vpc_config.security_group_ids
                                ) : (
                                    var.vpc_config.security_group_ids
                                )                                 

    metadata_options {
        http_endpoint           = "enabled"
        http_tokens             = "required"
    }

    root_block_device {
        encrypted               = true
        kms_key_id              = local.conditions.provision_kms_key ? (
                                    module.kms[0].key.id
                                ) : (
                                    var.ec2_config.kms_key_id
                                )
    }
}