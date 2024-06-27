resource "aws_key_pair" "ssh_key" {
    count                        = local.conditions.provision_ssh_key ? 1 : 0

    key_name                     = "${local.prefix}_key"
    public_key                   = tls_private_key.rsa[0].public_key_openssh
}


resource "tls_private_key" "rsa" {
    count                        = local.conditions.provision_ssh_key ? 1 : 0

    algorithm                    = local.ssh_key_defaults.algorithm
    rsa_bits                     = local.ssh_key_defaults.bits
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
    ebs_optimized               = local.ec2_defaults.ebs_optimized
    key_name                    = local.ssh_key_name
    iam_instance_profile        = var.ec2_config.instance_profile
    instance_type               = var.ec2_config.type
    monitoring                  = local.ec2_defaults.monitoring
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

    lifecycle {
        # TF is interpretting the tag calculations as a modification everytime 
        #   a plan is run, so ignore until issue is resuled.
        ignore_changes          = [
                                    tags,
                                ]
    }
    
    # ENFORCING TOKENS BREAKS CURRENT BOOTSTRAPPING PROCESS! - Grant Moore, 2024/6/27
    #   bootstrap hydrates from metadata server!
    
    # metadata_options {
    #     http_endpoint           = "enabled"
    #     http_tokens             = "required"
    # }

    # CURRENT AMI BUILD PROCESS BAKES DEVICE MAPPINGS INTO THE IMAGE
    #   ENFORCING BLOCK DEVICE MAPPINGS AT THE TF LEVEL CONFLICTS WITH
    #   AMI MAPPINGS, FORCING REDEPLOYMENT! 

    # root_block_device {
    #     encrypted               = local.ec2_defaults.encrypted
    #     kms_key_id              = local.kms_key_id
    #     volume_size             = var.ec2_config.root_block_device.volume_size
    #     volume_type             = var.ec2_config.root_block_device.volume_type
    # }

    # dynamic "ebs_block_device" {
    #     for_each                = { 
    #                                 for index, device in var.ec2_config.ebs_block_devices:
    #                                 index => device
    #                             }
    #     content {
    #         encrypted           = local.ec2_defaults.encrypted
    #         kms_key_id          = local.kms_key_id
    #         tags                = local.tags
    #         device_name         = ebs_block_device.value.device_name
    #         volume_size         = ebs_block_device.value.volume_size
    #         volume_type         = ebs_block_device.value.volume_type
    #     }
    # }
}