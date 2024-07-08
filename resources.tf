resource "aws_key_pair" "ssh_key" {
    count                        = local.conditions.provision_ssh_key ? 1 : 0

    key_name                     = module.platform.prefixes.security.pem_key
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
    filename                    = "${path.root}/keys/${module.platform.prefixes.security.pem_key}"
}


resource "aws_security_group" "remote_access_sg" {
    count                       = local.conditions.provision_sg ? 1 : 0

    name                        = "${module.platform.prefixes.security.group}-EC2"
    description                 = "${module.platform.prefixes.compute.ec2.instance} security group"
    vpc_id                      = module.platform.network.vpc.id
    tags                        = local.tags
}


resource "aws_security_group_rule" "remote_access_ingress" {
    count                       = local.conditions.provision_sg ? 1 : 0

    description                 = "Restrict access to VPC CIDR block"
    type                        = "ingress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = [ module.platform.network.vpc.cidr_block ]
    security_group_id           = aws_security_group.remote_access_sg[count.index].id
} 


resource "aws_security_group_rule" "remote_access_egress" {
    count                       = local.conditions.provision_sg ? 1 : 0

    description                 = "Allow all outgoing traffic"
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = [ "0.0.0.0/0" ]
    security_group_id           = aws_security_group.remote_access_sg[count.index].id
}

#tfsec:ignore:AVD-AWS-0131
resource "aws_instance" "instance" {
    ami                         = data.aws_ami.latest.id
    associate_public_ip_address = local.ec2_defaults.associate_public_ip_address
    ebs_optimized               = local.ec2_defaults.ebs_optimized
    key_name                    = local.ssh_key_name
    iam_instance_profile        = var.ec2.instance_profile
    instance_type               = var.ec2.type
    monitoring                  = local.ec2_defaults.monitoring
    # TODO: there could be multiple subnets in a given availability zone.
    #       the next line is simply taking the first one it finds. should 
    #       probably randomize the selection (i.e. choose a random number
    #       between 0 and (n-1), where n is `length(module.platform.subnets.id)`)
    subnet_id                   = module.platform.network.subnets.ids[0]
    tags                        = local.tags
    user_data                   = local.user_data
    vpc_security_group_ids      = local.vpc_security_group_ids
    
    lifecycle {
        # TF is interpretting the tag calculations as a modification everytime 
        #   a plan is run, so ignore until issue is resuled.
        ignore_changes          = [ tags ]
    }
    ## ENFORCING TOKENS BREAKS CURRENT BOOTSTRAPPING PROCESS! - Grant Moore, 2024/06/27
    ##   bootstrap hydrates from metadata server!
    
    # metadata_options {
    #     http_endpoint           = "enabled"
    #     http_tokens             = "required"
    # }

    ## CURRENT AMI BUILD PROCESS BAKES DEVICE MAPPINGS INTO THE IMAGE
    ##   ENFORCING BLOCK DEVICE MAPPINGS AT THE TF LEVEL CONFLICTS WITH
    #   AMI MAPPINGS, FORCING REDEPLOYMENT! - Grant Moore, 2024/06/27

    # root_block_device {
    #     encrypted               = local.ec2_defaults.encrypted
    #     kms_key_id              = local.kms_key_id
    #     volume_size             = var.ec2.root_block_device.volume_size
    #     volume_type             = var.ec2.root_block_device.volume_type
    # }

    # dynamic "ebs_block_device" {
    #     for_each                = { 
    #                                 for index, device in var.ec2.ebs_block_devices:
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