.PHONY: init fmt plan bootstrap up down

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

up: bootstrap

down:
	terraform -chdir=infra destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"
