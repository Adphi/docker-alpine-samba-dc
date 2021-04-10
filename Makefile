VERSION := 4.13.7

REGISTRY := adphi
IMAGE := samba-ad

CLIENT := samba-ad-client

.PHONY: version

version: build-client
	@$(eval NEW_VERSION=$(shell docker run --rm -i -t $(REGISTRY)/$(CLIENT) samba-tool --version|tail -n 1))
	@echo "setting version $(NEW_VERSION)"
	@sed -i 's|VERSION := $(VERSION)|VERSION := $(NEW_VERSION)|' Makefile

.PHONY: build-client
build-client:
	@docker image build -t $(REGISTRY)/$(CLIENT) -f client.Dockerfile .

.PHONY: build
build: version
	@docker buildx build . --platform=linux/amd64,linux/arm/v7 --push --tag $(REGISTRY)/$(IMAGE):$(VERSION) --tag $(REGISTRY)/$(IMAGE):latest
	@docker buildx build -f client.Dockerfile . --platform=linux/amd64,linux/arm/v7 --push --tag $(REGISTRY)/$(CLIENT):$(VERSION) --tag $(REGISTRY)/$(CLIENT):latest

