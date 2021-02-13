VERSION ?= 4.12.6

CLIENT := samba-ad-client

.PHONY: version

version: build-client
	@$(eval NEW_VERSION=$(shell docker run --rm -i -t $(CLIENT) samba-tool --version))
	@@sed -i -E 's%VERSION \:\= (.+)%VERSION \?\= ${NEW_VERSION}%' Makefile

.PHONY: build-client
build-client:
	@docker image build -t $(CLIENT) -f client.Dockerfile .

.PHONY: build
build: version
	@docker buildx build . --platform=linux/amd64,linux/arm/v7 --push --tag adphi/samba-ad:$(VERSION)
	@docker buildx build -f client.Dockerfile . --platform=linux/amd64,linux/arm/v7 --push --tag adphi/samba-ad:$(VERSION)

