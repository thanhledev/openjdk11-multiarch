PLATFORMS = linux/amd64,linux/arm64,linux/arm/v7
VERSION = $(shell cat VERSION)
BINFMT = a7996909642ee92942dcd6cff44b9b95f08dad64
ifeq ($(REPO),)
  REPO = ubuntu-openjdk11-multiarch
endif
ifeq ($(CIRCLE_TAG),)
	TAG = latest
else
	TAG = $(CIRCLE_TAG)
endif

.PHONY: all init build clean

all: init build clean

init: clean
	@docker run --rm --privileged docker/binfmt:$(BINFMT)
	@docker buildx create --name jdk_builder
	@docker buildx use jdk_builder
	@docker buildx inspect --bootstrap

build:
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
	@docker buildx build \
			--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
			--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
			--build-arg VCS_URL=$(shell git config --get remote.origin.url) \
			--build-arg VERSION=$(VERSION) \
			--platform $(PLATFORMS) \
			--push \
			-t $(REPO):$(TAG) .
	@docker logout

clean:
	@docker buildx rm jdk_builder | true
