.PHONY: init plan bootstrap provision up down


ENV := dev

ifdef CI
	ENV := ci
	AWS_REGION := ${AWS_REGION}
else
	AWS_REGION := $(shell aws configure get region)
endif


init:
	cd infra/live/${ENV}/artifactory && terragrunt init

plan:
	cd infra/live/${ENV}/artifactory && terragrunt plan -var "user=${USER}" -var "aws_region=${AWS_REGION}"

bootstrap:
	-cd infra/live/${ENV}/artifactory && terragrunt apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

up: bootstrap provision

down:
	cd infra/live/${ENV}/artifactory && terragrunt destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

provision:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" ansible-playbook -e REGION=${AWS_REGION} ./provision/main.yml
