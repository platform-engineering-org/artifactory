.PHONY: init plan bootstrap provision up down

ENV := dev

ifeq ($(ENV), dev)
	AWS_REGION := $(shell aws configure get region)
	AWS_PROFILE := default
else ifeq ($(ENV), ci)
	AWS_REGION := ${AWS_REGION}
else ifeq ($(ENV), stage)
	AWS_REGION := ${AWS_REGION}
	AWS_PROFILE := stage
endif


init:
	cd infra/live/${ENV}/artifactory && terragrunt init

plan:
	cd infra/live/${ENV}/artifactory && terragrunt plan -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

bootstrap:
	-cd infra/live/${ENV}/artifactory && terragrunt apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

up: bootstrap provision

down:
	cd infra/live/${ENV}/artifactory && terragrunt destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

provision:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" AWS_PROFILE=${AWS_PROFILE} ansible-playbook -e ENV=${ENV} ./provision/main.yml
