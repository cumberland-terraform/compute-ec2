# Enterprise Terraform 
## Cumberland Cloud Compute Elastic Compute Cloud
### Overview

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

	source 					= "github.com/cumberland-terraform/orchestrate-build.git"
	
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

