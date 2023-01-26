.PHONY: init plan bootstrap provision up down init-in-container plan-in-container bootstrap-in-container provision-in-container down-in-container

ENV := dev

ifeq ($(ENV), dev)
	ifndef AWS_REGION
	    AWS_REGION := $(shell aws configure get region)
	endif
	AWS_PROFILE := default
	ENGINE := podman
else ifeq ($(ENV), ci)
	AWS_REGION := ${AWS_REGION}
	ENGINE := docker
else ifeq ($(ENV), stage)
	AWS_REGION := ${AWS_REGION}
	AWS_PROFILE := stage
	ENGINE := podman
endif

HELPER_IMAGE := ghcr.io/platform-engineering-org/helper:latest
in_container = ${ENGINE} run --rm --name helper -v $(PWD):/workspace:rw -v ~/.aws:/root/.aws:ro -w /workspace --security-opt label=disable --env USER=${USER} --env AWS_REGION=${AWS_REGION} ${HELPER_IMAGE} make $1
TERRAGRUNT_CMD = cd infra/live/${ENV}/artifactory && terragrunt


init-in-container:
	${TERRAGRUNT_CMD} init

plan-in-container:
	${TERRAGRUNT_CMD} plan -out stam -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

bootstrap-in-container:
	-${TERRAGRUNT_CMD} apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

provision-in-container:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" AWS_PROFILE=${AWS_PROFILE} ansible-playbook -e ENV=${ENV} ./provision/main.yml

down-in-container:
	${TERRAGRUNT_CMD} destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

init:
	$(call in_container,init-in-container)

plan:
	$(call in_container,plan-in-container)

bootstrap:
	$(call in_container,bootstrap-in-container)

up:
	$(call in_container,bootstrap-in-container provision-in-container)

down:
	$(call in_container,down-in-container)

provision:
	$(call in_container,provision-in-container)
