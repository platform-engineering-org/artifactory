.PHONY: init fmt plan bootstrap provision up down

ifeq ($(AWS_REGION),)
AWS_REGION := $(shell aws configure get region)
endif

init:
	terraform -chdir=infra init

fmt:
	terraform -chdir=infra fmt -check

plan:
	terraform -chdir=infra plan -var "user=${USER}" -var "aws_region=${AWS_REGION}" -input=false

bootstrap:
	terraform -chdir=infra apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -input=false

provision:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" ansible-playbook -e REGION=${AWS_REGION} ./provision/main.yml

up: bootstrap provision

down:
	terraform -chdir=infra destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"
