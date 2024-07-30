# CHANGELOG

## Version 1.0.0

- Module use the [mdt-eter-platform](LINK GOES HERE) module to ensure new EC2s have platform compliant names, tags, security group and subnet placing. 
- Module accepts a pre-existing KMS to encrypt resources, but if one is not provided, a new KMS key is automatically provisioned, ensuring unencrypted resources are never provisioned.
- Module will use platform SSH key, but a `null` can be passed in for the `ec2.ssh_key_name` property. Doing so will force the module to provision a new private-public PEM key pairing. The resulting private key will be stored in a SecretManager secret. Access will be given to all IAM principals in the target account by default.
- Module accepts an operating system through the `ec2.operating_system` property and dynamically injects the appropriate platform user-data script. 
- Module accepts the argument `ec2.provision_sg`. If this argument is set to `true`, a new security group will be provisioned and the EC2 will be deployed into this group. By default, the VPC CIDR of the target account will be allowed ingress on all ports. By default, this argument is set to `false`, meaning no additional security will be provisioned. **NOTE**: all new instances are deployed into the `DMEM` and `RHEL` security groups by default; this functionality cannot be changed. The `ec2.provision_sg` argument merely adds an additional security group to this list.