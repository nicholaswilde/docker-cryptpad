include make_env

NS ?= nicholaswilde
VERSION ?= 1.8.7
LS ?= 01

IMAGE_NAME ?= cryptpad
CONTAINER_NAME ?= cryptpad
CONTAINER_INSTANCE ?= default

.PHONY: push push-latest run rm help vars test

## all		: Build all platforms
all: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile .

## build		: build the current platform (default)
build: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) -f Dockerfile .

## test		: test build the current platform
test: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) -f Dockerfile . --progress=plain --no-cache

## build-latest	: Build the latest current platform
build-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest --build-arg VERSION=$(VERSION) -f Dockerfile .

## load   	: Load the release image
load: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) -f Dockerfile --load .

## load-latest  	: Load the latest image
load-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest -f Dockerfile --load .

## push   	: Push the release image
push: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-latest  	: PUsh the latest image
push-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-all 	: Push all release platform images
push-all: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-arm     : Push all release platform images
push-arm: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):arm-$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-arm-latest     : Push all release platform images
push-arm-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):arm-latest --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-quay-arm     : Push all release platform images
push-quay-arm: Dockerfile
	docker buildx build -t quay.io/$(NS)/$(IMAGE_NAME):arm-$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-quay-latest-arm     : Push all release platform images
push-quay-latest-arm: Dockerfile
	docker buildx build -t quay.io/$(NS)/$(IMAGE_NAME):arm-latest --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-quay	:
push-quay: Dockerfile
	docker buildx build -t quay.io/$(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-quay-latest	: 
push-quay-latest: Dockerfile
	docker buildx build -t quay.io/$(NS)/$(IMAGE_NAME):latest $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-github	: 
push-github: Dockerfile
	docker buildx build -t ghcr.io/$(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-github-latest	:
push-github-latest: Dockerfile
	docker buildx build -t ghcr.io/$(NS)/$(IMAGE_NAME):latest $(PLATFORMS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-quay-arm     : Push all release platform images
push-github-arm: Dockerfile
	docker buildx build -t ghcr.io/$(NS)/$(IMAGE_NAME):arm-$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## push-quay-latest-arm     : Push all release platform images
push-github-latest-arm: Dockerfile
	docker buildx build -t ghcr.io/$(NS)/$(IMAGE_NAME):arm-latest --build-arg VERSION=$(VERSION) -f Dockerfile --push .

## rm   		: Remove the container
rm: stop
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

## run    	: Run the Docker image
run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS)

## rund   	: Run the Docker image in the background
rund:
	docker run -d --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS)

## stop   	: Stop the Docker container
stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

## shell		: Get a shell
shell:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) /bin/sh

## help   	: Show help
help: Makefile
	@sed -n 's/^##//p' $<

## vars   	: Show all variables
vars:
	@echo VERSION   : $(VERSION)
	@echo NS        : $(NS)
	@echo IMAGE_NAME      : $(IMAGE_NAME)
	@echo CONTAINER_NAME    : $(CONTAINER_NAME)
	@echo CONTAINER_INSTANCE  : $(CONTAINER_INSTANCE)
	@echo PORTS : $(PORTS)
	@echo ENV : $(ENV)
	@echo PLATFORMS : $(PLATFORMS)
	@echo PLATFORMS_ARM : $(PLATFORMS_ARM)

default: build
