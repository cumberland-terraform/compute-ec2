# Enterprise Terraform 
## Cumberland Cloud Platform
## AWS Compute - EC2

This is the baseline module for a standalone **EC2** instance on the **Cumberland Cloud**. It has been setup with ease of deployment in mind, so that platform compliant compute space be easily provisioned with minimum configuration.

### Usage

The bare minimum deployment can be achieved with the following configuration,

**providers.tf**

```hcl
provider "aws" {
	alias 					= "tenant"
	region					= "us-east-1"

	assume_role {
		role_arn 			= "arn:aws:iam::<tenant-account>:role/<role-name>"
	}
}
```

**modules.tf**

```
module "server" {
	source 					= "https://github.com/cumberland-terraform/compute-ec2.git"

	providers				= {
		aws 				= aws.tenant
	}

	platform				= {
		client          	= "<client>"
    	environment         = "<environment>"
	}

	ec2						= {
		operating_system	= "<operating-system>"
	}

	kms 					= {
		aws_managed 		= true
	}
}
```

### Parameters

The `ec2` object represents the configuration for a new deployment. Only one fields is absolutely required: `operating_system`. See previous section for example usage. The following bulleted list shows the hierarchy of allowed values for the `ec2` object fields and their purpose,

- `operating_system`: (*Required*) Operating system for the instance. 
- `tags`: (*Optional*) A map of tags to append to the resource in additional to the platform tags which are appended by default.
- `vpc_security_group_ids`: (*Optional*) A list of IDs for the security groups into which the new instance will be deployed. **NOTE**: If no security groups are provided, a new security group will automatically be provisioned.
- `root_block_device`: (*Optional*) Object that represents the configuration for the root block device. **NOTE**: this variable currently does nothing, as the root block device is baked into the AMI during the image build. It has been left in place for an eventual shift of workload to IaC.
	- `volume_type`: (*Required*) Type of volume to be provisioned.
	- `volume_size`: (*Required*) Size of the volume to be provisioned.
- `ebs_block_devices`: (*Optional*) List of block devices to attach to the EC2. **NOTE**: this variable currently does nothing, as all  block device are baked into the AMI during the image build. It has been left in place for an eventual shift of workload to IaC.
- `iam_instance_profile`: (*Optional*) The name of the instance profile for the instance to assume. 
- `type`: (*Optional*) Type of the instance to deploy. Defaults to `t3.xlarge`. 
- `ssh_key_name`: (*Optional*) Name of the AWS managed PEM to associate with the instance. If no key name is provided, a new SSH key will be generated and stored in the AWS secret manager with the appropriate platform prefix.
- `provision_sg`: (*Optional*) A boolean flag to signal to the module to provision a new security group for the instance that allows ingress from all addresses in the target VPC. Defaults to `false`, i.e. no security group is provisioned by default.
- `userdata`: (*Optional*) Userdata script that overrides the default userdata. 

The `kms` object represents the configuration the KMS key used to encrypt resources.

- `id`: Physical ID of the KMS key.
- `arn`: AWS ARN of the KMS key.
- `alias_arn`: AWS Alias ARN of the KMS key. 
- `aws_managed`: Boolean flag to use AWS managed key instead of CMK. This argument takes precedence over all others, i.e. if this argument is set to `true`, all the other arguments will be ignored.

The `suffix` variable is the naming suffix appended to all resources after the platform prefix,