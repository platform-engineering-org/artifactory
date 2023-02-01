# artifactory

IaC Spinning Artifactory instance on AWS

## local DEV environment

### System Requirements

* AWS [credentials settings][1], profile __default__
* Define a secret in AWS Secrets Manager:
  * Secret name: artifactory
  * key __artifactory_license_1__
  * key __username__ (value must be lowercase)
  * key __password__ (value must be lowercase)
* `make`
* `podman` or `docker`

### pre-commit

To run pre-commit locally, follow the instructions:

```shell
pip install --user pre-commit
pre-commit install
```

### DEV Environment init

```shell
make init
```

### DEV Environment reconfigure

```shell
make reconfigure
```

### DEV Environment Up

```shell
make up
```

### DEV Environment Down

```shell
make down
```

## STAGE environment

* Setup AWS profile named __stage__
* Define a secret in AWS Secrets Manager:
  * Secret name: artifactory
  * key __artifactory_license_2__
  * key __username__ (value must be lowercase)
  * key __password__ (value must be lowercase)
* `make`
* `podman` or `docker`

### STAGE Environment init

```shell
make init
```

### STAGE Environment reconfigure

```shell
make reconfigure
```

### STAGE Environment Up

```shell
make ENV=stage up
```

### STAGE Environment Down

```shell
make ENV=stage down
```

[1]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
