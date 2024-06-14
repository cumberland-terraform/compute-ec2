# Enterprise Terraform 
## AWS Core Compute

Documentation goes here.

### Usage

```
module "mymodule" {
	source          = "source goes here"
	
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

(Future State) 
Jenkins will run on PR requests from ``feature/*`` to ``master``. 
NOTE: we could turn on SCM polling to accomplish this, but would be expensive.
(Future State)

### Pull Request Checklist

- [] Update Changelog
- [] Open PR into ``master`` branch
- [] Ensure tests are passing in Jenkins
- [] Get approval from lead
- [] Tag latest commit with new version
- [] Publish version to Confluence

### Versioning

TODO
