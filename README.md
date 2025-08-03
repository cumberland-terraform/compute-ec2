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

`platform` is a parameter for *all* **Cumberland Cloud** modules. For more information about the `platform`, in particular the permitted values of the nested fields, see the ``platform`` module documentation. 

## KMS Key Deployment Options

### 1: Module Provisioned Key

If the `var.kms` is set to `null` (default value), the module will attempt to provision its own KMS key. This means the role assumed by Terraform in the `provider` 

### 2: User Provided Key

If the user of the module prefers to use a pre-existing customer managed key, the `id`, `arn` and `alias_arn` of the `var.kms` variable must be passed in. This will override the provisioning of the KMS key inside of the module.

### 3: AWS Managed Key

If the user of the module prefers to use an AWS managed KMS key, the `var.kms.aws_managed` property must be set to `true`.
