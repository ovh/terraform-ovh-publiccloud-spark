OS_REGION_NAME ?= GRA3
PACKERBIN ?= $(shell which packer-io || which packer)

all:

.terraform:
	@terraform init

ext_net_id:
	@terraform apply -var region=$(OS_REGION_NAME) > /dev/null 2>&1

centos7-spark: ext_net_id
	$(PACKERBIN) build -var region=$(OS_REGION_NAME) \
	           	  -var ext_net_id=$(shell terraform output | awk -F 'ext_net_id = ' '/ext_net_id/ {print $$2}') \
				  centos7-spark.json
