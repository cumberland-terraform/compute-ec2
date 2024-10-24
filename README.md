# Enterprise Terraform 
## AWS Core Compute Elastic Compute Cloud
### Overview

This is the baseline module for a standalone **EC2** instance on the **MDThink Platform**. It has been setup with ease of deployment in mind, so that platform compliant compute space be easily provisioned with minimum configuration.

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
	source 					= "ssh://git@source.mdthink.maryland.gov:22/etm/mdt-eter-aws-core-compute-ec2.git?ref=v1.0.0"

	providers				= {
		aws 				= aws.tenant
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

`platform` is a parameter for *all* **MDThink Enterprise Terraform** modules. For more information about the `platform`, in particular the permitted values of the nested fields, see the [mdt-eter-platform documentation](https://source.mdthink.maryland.gov/projects/etm/repos/mdt-eter-platform/browse). The following section goes into more detail regarding the `ec2` variable.

### Parameters

The `ec2` object represents the configuration for a new deployment. Only two fields are absolutely required: `operating_system` and `tags`. See previous section for example usage. The following bulleted list shows the hierarchy of allowed values for the `ec2` object fields and their purpose,

- `operating_system`: (*Required*) Operating system for the instance. Currently supported values are: `RHEL7`, `RHEL8`, `Windows2012R2`, `Windows2016`, `Windows2019`, `Windows2022`.
- `tags`: (*Required*) Tag configuration object.
	- `builder`: (*Required*) Person or process responsible for provisioning.
	- `primary_contact`: (*Required*) Contact information for the owner of the instance.
	- `owner`: (*Required*) Name of the owner.
	- `purpose`: (*Required*) Description of the server. 
	- `rhel_repo`: (*Optional*) Defaults to `NA`
	- `schedule`: (*Optional*) Defaults to `never`.
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
- `kms_key`: (*Optional*) KMS key object used to encrypt block devices. If no KMS key is provided, a new KMS key will be provisioned and access will be provided to the instance profile IAM role. The AWS managed default `ebs` key can be used by specifying `aws_managed = true`. If `aws_managed` is set, all other arguments are ignored.
	- `id`: Physical ID of the KMS key.
	- `arn`: AWS ARN of the KMS key.
	- `alias_arn`: AWS Alias ARN of the KMS key. 
	- `aws_managed`: Boolean flag to use AWS managed key instead of CMK. This argument takes precedence over all others, i.e. if this argument is set to `true`, all the other arguments will be ignored.
- `provision_sg`: (*Optional*) A boolean flag to signal to the module to provision a new security group for the instance that allows ingress from all addresses in the target VPC. Defaults to `false`, i.e. no security group is provisioned by default.
- `userdata`: (*Optional*) Userdata script that overrides the default userdata. 

## Contributing
The below instructions are to be performed within Unix-style terminal. 

It is recommended to use Git Bash if using a Windows machine. Installation and setup of Git Bash can be found [here](https://git-scm.com/downloads/win)

### Step 1: Clone Repo

Clone the repository. Details on the cloning process can be found [here](https://support.atlassian.com/bitbucket-cloud/docs/clone-a-git-repository/)

If the repository is already cloned, ensure it is up to date with the following commands,

If you already have the repository cloned locally, execute the following commands to update your local repo:
```bash
git checkout master
git pull
```

### Step 2: Create Branch

Create a branch from the `master` branch. The branch name should be formatted as follows:

	feature/<TICKET_NUMBER>

Where the value of `<TICKET_NUMBER>` is the ticket for which your work is associated. 

The basic command for creating a branch is as follows:

```bash
git checkout -b feature/<TICKET_NUMBER>
```

For more information, refer to the documentation [here](https://docs.gitlab.com/ee/tutorials/make_first_git_commit/#create-a-branch-and-make-changes)

### Step 3: Commit Changes

Update the code and commit the changes,

```bash
git commit -am "<TICKET_NUMBER> - description of changes"
```

More information on commits can be found in the documentation [here](https://docs.gitlab.com/ee/tutorials/make_first_git_commit/#commit-and-push-your-changes)

### Step 4: Merge With Master On Local


```bash
git checkout master
git pull
git checkout feature/<TICKET_NUMBER>
git merge master
```

For more information, see [git documentation](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)


### Step 5: Push Branch to Remote

After committing changes, push the branch to the remote repository,

```bash
git push origin feature/<TICKET_NUMBER>
```

### Step 6: Pull Request

Create a pull request. More information on this can be found [here](https://www.atlassian.com/git/tutorials/making-a-pull-request).

Once the pull request is opened, a pipeline will kick off and execute a series of quality gates for linting, security scanning and testing tasks.

### Step 7: Merge

After the pipeline successfully validates the code and the Pull Request has been approved, merge the Pull Request in `master`.

After the code changes are in master, the new version should be tagged. To apply a tag, the following commands can be executed,

```bash
git tag v1.0.1
git push tag v1.0.1
```

Update the `CHANGELOG.md` with information about changes.


### Pull Request Checklist

Ensure each item on the following checklist is complete before updating any tenant deployments with a new version of this module,

- [] Merge `master` into `feature/*` branch
- [] Open PR from `feature/*` branch into `master` branch
- [] Ensure tests are passing in Jenkins
- [] Get approval from lead
- [] Merge into `master`
- [] Increment `git tag` version
- [] Update Changelog
- [] Publish latest version on Confluence

