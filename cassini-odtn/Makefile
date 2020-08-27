DOCKER=docker
GROUP=sdnm
PROJECT=cassini-odtn
VERSION=latest
PORT_NETCONF=830
PORT_SSH=22
PORT_RESTCONF=8080
NAME=cassini-odtn

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

builder: ## Build ODTN cassini image
	@echo 'Building the container' \
	&& $(DOCKER) build -t $(GROUP)/$(PROJECT):$(VERSION) .

run: ## RUN ODTN cassini container
	@echo 'Running the container' \
	&& $(DOCKER) run -itd --privileged --name $(NAME) -p $(PORT_NETCONF):$(PORT_NETCONF) \
	-p $(PORT_SSH):$(PORT_SSH) -p $(PORT_RESTCONF):$(PORT_RESTCONF) --cap-add=NET_ADMIN \
	--cap-add=SYS_MODULE -v "/lib/modules:/lib/modules" $(GROUP)/$(PROJECT):$(VERSION)

start: ## Start ODTN cassini container
	@echo 'Starting the container' \
	&& $(DOCKER) start $(NAME)

stop: ## Stop ODTN cassini container
	@echo 'Stoping the container' \
	&& $(DOCKER) stop $(NAME)

del: ## Delete ODTN cassini container
	@echo 'Deleting the container' \
	&& $(DOCKER) rm $(NAME)

del-image: ## Delete ODTN cassini image
	@echo 'Deleting the container' \
	&& $(DOCKER) rmi $(GROUP)/$(PROJECT):$(VERSION)
