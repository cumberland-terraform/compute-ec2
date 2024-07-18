# Enterprise Terraform 
## AWS Core Compute Elastic Compute Cloud
### Overview

This is the baseline module for a standalone **EC2** instance on the **MDThink Platform**. It has been setup with ease of deployment in mind, so that platform compliant compute space be easily provisioned with minimum configuration.

### Usage

The bare minimum deployment can be achieved with the following configuration,

**providers.tf**

```hcl
provider "tls" { }

provider "aws" {
	region					= "us-east-1"

	assume_role {
		role_arn 			= "arn:aws:iam::<target-account>:role/IMR-MDT-TERA-EC2"
	}
}

provider "aws" {
	alias 					= "core"
	region 					= "us-east-1"
}
```

**modules.tf**

```
module "server" {
	source 					= "ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-aws-core-compute-ec2.git"

	providers				= {
		aws.core 			= aws.core
	}

	platform				= {
		aws_region 			= "<region-name>"
		account 			= "<account-name>"
		acct_env 			= "<account-environment>"
		agency 				= "<agency>"
		program 			= "<program>"
		app					= "<application>"
		app_env  			= "<application-environment>"
		domain 				= "<active-directory-domain>"
		pca 				= "<pca-code>"
		subnet_type 		= "<subnet-type>"
		availability_zones	= [ "<availability_zone>"]
	}

	ec2						= {
		operating_system	= "<RHEL8/RHEL7/Windows2012R2/Windows2016/Windows2019/Windows2022>"
		tags 				= {
			builder 		= "<Builder Name>"
			primary_contact	= "<Contact Information>"
			owner 			= "<Owner Information>"
			purpose 		= "<Description of Purpose>"
		}
	}
}
```

`platform` is a parameter for *all* **MDThink Enterprise Terraform** modules. For more information about the `platform`, in particular the permitted values of the nested fields, see the [mdt-eter-platform documentation](https://source.mdthink.maryland.gov/projects/ET/repos/mdt-eter-platform/browse). The following section goes into more detail regarding the `ec2` variable.

### Parameters

The `ec2` object represents the configuration for a new deployment. Only three fields are absolutely required: `operating_system`, `availability_zone` and `tags`. See previous section for example usage. The following bulleted list shows the hierarchy of allowed values for the `ec2` object fields and their purpose,

- `operating_system`: (*Required*) Operating system for the instance. Currently supported values are: `RHEL7`, `RHEL8`, `Windows2012R2`, `Windows2016`, `Windows2019`, `Windows2022`
- `tags`: (*Required*) Tag configuration object.
	- `builder`: (*Required*) Person or process responsible for provisioning.
	- `primary_contact`: (*Required*) Contact information for the owner of the instance.
	- `owner`: (*Required*) Name of the owner.
	- `purpose`: (*Required*) Description of the server. 
	- `rhel_repo`: (*Optional*) Defaults to *NA*
	- `schedule`: (*Optional*) Defaults to *never*.
	- `new_build`: (*Optional*). Boolean flagging instance as new. Defaults to `true`.
	- `auto_backup`: (*Optional*): Boolean flagging instance for automated backup. Defaults to `false`.
- `additional_security_group_ids`: (*Optional*) A list of IDs for the security groups into which the new instance will be deployed. *NOTE*: The instance will be deployed into platform security groups (such as *DMEM* and *RHEL*) automatically, so this list should only contain application specific security groups.
- `root_block_device`: (*Optional*) Object that represents the configuration for the root block device. **NOTE**: this variable currently does nothing, as the root block device is baked into the AMI during the image build. It has been left in place for an eventual shift of workload to IaC.
	- `volume_type`: (*Required*) Type of volume to be provisioned.
	- `volume_size`: (*Required*) Size of the volume to be provisioned.
- `ebs_block_devices`: (*Optional*) List of block devices to attach to the EC2. **NOTE**: this variable currently does nothing, as all  block device are baked into the AMI during the image build. It has been left in place for an eventual shift of workload to IaC.
- `iam_instance_profile`: (*Optional*) The name of the instance profile for the instance to assume. If not provided, this will default to the `IMR-<account>-NEWBUILD-EC2` role for the target account.
- `type`: (*Optional*) Type of the instance to deploy. Defaults to `t3.xlarge`. 
- `ssh_key_name`: (*Optional*) Name of the AWS managed PEM to associate with the instance. If no key name is provided, a new SSH key will be generated and stored in the AWS secret manager with the appropriate platform prefix.
- `suffix`: (*Optional*) Suffix to append to name of the instance. Defaults to a blank string.
- `kms_key`: (*Optional*) KMS key object used to encrypt block devices. If no KMS key is provided, a new KMS key will be provisioned and access will be provided to the instance profile IAM role.
	- `id`: Physical ID of the KMS key.
	- `arn`: AWS ARN of the KMS key.
- `provision_sg`: (*Optional*) A boolean flag to signal to the module to provision a new security group for the instance that allows ingress from all addresses in the target VPC. Defaults to `false`, i.e. no security group is provisioned by default.
- `userdata`: (*Optional*) Userdata script that overrides the default userdata. 

## Contributing

Checkout master and pull the latest commits,

```bash
git checkout master
git pull
```

Append ``feature/`` to all new branches.

```bash
git checkout -b feature/newthing
```

After committing your changes, push them to your feature branch and then merge them into the `test` branch. 

```bash
git checkout test && git merge feature/newthing
```

Once the changes are in the `test` branch, the Jenkins job containing the unit tests, linting and security scans can be run. Once the tests are passing, tag the latest commit,

```bash
git tag v1.0.1
```

Once the commit has been tagged, a PR can be made from the `test` branch into the `master` branch.

### Pull Request Checklist

Ensure each item on the following checklist is complete before updating any tenant deployments with a new version of the ``mdt-eter-core-compute-eks`` module,

- [] Update Changelog
- [] Open PR into `test` branch
- [] Ensure tests are passing in Jenkins
- [] Increment `git tag` version
- [] Merge PR into `test`
- [] Open PR from `test` into `master` branch
- [] Get approval from lead
- [] Merge into `master`
- [] Publish latest version on Confluence