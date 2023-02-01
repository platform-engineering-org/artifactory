.PHONY: init reconfigure upgrade plan bootstrap provision up down \
	init-in-container reconfigure-in-container upgrade-in-container \
	plan-in-container bootstrap-in-container provision-in-container \
	down-in-container

ENV := dev

ifndef OS_ENV
ifneq ($(shell which docker),)
ENGINE := docker
else ifneq ($(shell which podman),)
ENGINE := podman
else
$(error Container engine can't be found)
endif
endif

ifeq ($(ENV), dev)
	ifndef AWS_REGION
	    AWS_REGION := $(shell aws configure get region)
	endif
	AWS_PROFILE := default
else ifeq ($(ENV), ci)
	AWS_REGION := ${AWS_REGION}
else ifeq ($(ENV), stage)
	AWS_REGION := ${AWS_REGION}
	AWS_PROFILE := stage
endif

HELPER_IMAGE := ghcr.io/platform-engineering-org/helper:latest
in_container = ${ENGINE} run --rm --name helper -v $(PWD):/workspace:rw -v ~/.aws:/root/.aws:ro -w /workspace --security-opt label=disable --env USER=${USER} --env AWS_REGION=${AWS_REGION} --env OS_ENV=container ${HELPER_IMAGE} make $1
TERRAGRUNT_CMD = cd infra/live/${ENV}/artifactory && TF_LOG=DEBUG terragrunt


init-in-container:
	${TERRAGRUNT_CMD} init

reconfigure-in-container:
	${TERRAGRUNT_CMD} init --reconfigure

upgrade-in-container:
	${TERRAGRUNT_CMD} init -upgrade

plan-in-container:
	${TERRAGRUNT_CMD} plan -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

bootstrap-in-container:
	-${TERRAGRUNT_CMD} apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

provision-in-container:
	ansible-galaxy install -r ./provision/requirements.yml
	ANSIBLE_CONFIG="./provision/ansible.cfg" AWS_PROFILE=${AWS_PROFILE} ansible-playbook -e ENV=${ENV} ./provision/main.yml

down-in-container:
	${TERRAGRUNT_CMD} destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

init:
	$(call in_container,init-in-container)

reconfigure:
	$(call in_container,reconfigure-in-container)

upgrade:
	$(call in_container,upgrade-in-container)

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
