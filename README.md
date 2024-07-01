# Enterprise Terraform 
## AWS Core Compute
### EC2

Documentation goes here.

### Usage

```
module "mymodule" {
	source          = "ssh://git@source.mdthink.maryland.gov:22/et/mdt-eter-aws-core-compute.git"
	
	# vars go here

}
```

## Contributing

### Development

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

Once the changes are in the `test` branch, the Jenkins job containing the unit tests, linting and security scans can be run. Once the tests are passing, a PR can be made from the `test` branch into the `master` branch.

### Pull Request Checklist

- [] Update Changelog
- [] Open PR into ``master`` branch
- [] Ensure tests are passing in Jenkins on ``test`` branch.
- [] Get approval from lead and one other team member
- [] Tag latest commit with new version
- [] Merge into master

### Versioning

TODO
