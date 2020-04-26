
PHONY: build
build:
	@docker buildx build . --platform=linux/amd64,linux/arm/v7 --push --tag adphi/alpine-samba-dc
