# artifactory

IaC Spinning Artifactory instance on AWS

## local DEV environment

### System Requirements

* AWS [credentials settings][1]
* AWS Region - Currently must be `eu-west-2`
* Artifactory license stored in AWS Secrets Manager. Secret name: artifactory.
  key name - artifactory_license_1
* make
* terraform
* ansible

### pre-commit

To run pre-commit locally, follow the instructions:

```shell
pip install --user pre-commit
pre-commit install
```

### Environment Up

```shell
make up
```

### Environment Down

```shell
make down
```

[1]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
