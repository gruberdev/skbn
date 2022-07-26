GIT_VERSION := $(shell git describe --match "v[0-9]*")
GIT_BRANCH := $(shell git branch | grep \* | cut -d ' ' -f2)
GIT_HASH := $(GIT_BRANCH)/$(shell git log -1 --pretty=format:"%H")
TIMESTAMP := $(shell date '+%Y-%m-%d_%I:%M:%S%p')
REGISTRY := ghcr.io
REPO ?= $(REGISTRY)/skbn
IMAGE_TAG := $(GIT_VERSION)
GOOS := $(shell go env GOOS)
PACKAGE := github.com/gruberdev/skbn
SKBN_PATH := cmd/skbn.go
SKBN_IMAGE := skbn
LD_FLAGS="-s -w -X $(PACKAGE)/pkg/version.BuildVersion=$(GIT_VERSION) -X $(PACKAGE)/pkg/version.BuildHash=$(GIT_HASH) -X $(PACKAGE)/pkg/version.BuildTime=$(TIMESTAMP)"

all: skbn

.PHONY: local
local:
	go build -ldflags=$(LD_FLAGS) $(SKBN_PATH)

.PHONY: skbn
skbn:
	GOOS=$(GOOS) go build -o skbn -ldflags=$(LD_FLAGS) $(SKBN_PATH)

.PHONY: docker-publish-skbn docker-build-skbn docker-push-skbn
docker-publish-skbn: docker-build-skbn docker-push-skbn

docker-build-skbn:
	@docker buildx build . --progress plane --platform linux/arm64,linux/amd64 --tag $(REPO)/$(SKBN_IMAGE):$(IMAGE_TAG) --build-arg LD_FLAGS=$(LD_FLAGS)

docker-push-skbn:
	@docker buildx build . --progress plane --push --platform linux/arm64,linux/amd64 --tag $(REPO)/$(SKBN_IMAGE):$(IMAGE_TAG) --build-arg LD_FLAGS=$(LD_FLAGS)
	@docker buildx build . --progress plane --push --platform linux/arm64,linux/amd64 --tag $(REPO)/$(SKBN_IMAGE):latest --build-arg LD_FLAGS=$(LD_FLAGS)