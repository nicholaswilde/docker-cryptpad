include make.env

BUILD_DATE ?= $(shell date -u +%Y-%m-%dT%H%M%SZ)

BUILD = --build-arg VERSION=$(VERSION) --build-arg CHECKSUM=$(CHECKSUM) --build-arg BUILD_DATE=$(BUILD_DATE)

.PHONY: push push-latest run rm help vars test

## all		: Build all platforms
all: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) $(BUILD) -f Dockerfile .

## build		: build the current platform (default)
build: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(BUILD) -f Dockerfile .

## build-latest	: Build the latest current platform
build-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest --build-arg VERSION=$(VERSION) --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile .

## checksum	: Get the checksum of a file
checksum:
	wget -qO- "https://github.com/xwiki-labs/$(IMAGE_NAME)/archive/${VERSION}.tar.gz" | sha256sum

## date		: Show the date
date:
	docker run --rm $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) date

## lint		: Lint the Dockerfile with hadolint
lint:	Dockerfile
	hadolint Dockerfile && yamllint .

## load   	: Load the release image
load: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) -f Dockerfile --load .

## load-latest  	: Load the latest image
load-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest -f Dockerfile --load .

## monitor	: Monitor the image with snyk
monitor:
	snyk container monitor $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS)

## push   	: Push the release image
push: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --build-arg VERSION=$(VERSION) --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile --push .

## push-latest  	: PUsh the latest image
push-latest: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):latest $(PLATFORMS) --build-arg VERSION=$(VERSION) --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile --push .

## push-all 	: Push all release platform images
push-all: Dockerfile
	docker buildx build -t $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) $(PLATFORMS) --build-arg VERSION=$(VERSION) --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile --push .

## rm   		: Remove the container
rm: stop
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

## run    	: Run the Docker image
run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS)

## rund   	: Run the Docker image in the background
rund:
	docker run -d --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS)

## shell		: Get a shell
shell:
	docker run -it --rm $(PORTS) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) /bin/sh

## stop   	: Stop the Docker container
stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

## test		: Test the image with snyk
test:
	snyk container test $(NS)/$(IMAGE_NAME):$(VERSION)-ls$(LS) --file=Dockerfile

## prune		: Prune builder
prune:
	docker builder prune -f

## help   	: Show help
help: Makefile
	@sed -n 's/^##//p' $<

## vars   	: Show all variables
vars:
	@printf "VERSION 		: %s\n" "$(VERSION)"
	@printf "NS        		: %s\n" "$(NS)"
	@printf "IMAGE_NAME		: %s\n" "$(IMAGE_NAME)"
	@printf "CONTAINER_NAME		: %s\n" "$(CONTAINER_NAME)"
	@printf "CONTAINER_INSTANCE	: %s\n" "$(CONTAINER_INSTANCE)"
	@printf "PORTS 			: %s\n" "$(PORTS)"
	@printf "ENV 			: %s\n" "$(ENV)"
	@echo "PLATFORMS 		: $(PLATFORMS)"
	@printf "CHECKSUM 		: %s\n" "$(CHECKSUM)"
	@printf "BUILD_DATE 		: %s\n" "$(BUILD_DATE)"
	@printf "BUILD 			: %s\n" "$(BUILD)"

default: build
