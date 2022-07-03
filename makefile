REGISTRY := docker.io/agaia
NAME := dev
TAG := 0.0.1
IMAGE := $(REGISTRY)/$(NAME)
IMAGE_VERSIONED := $(IMAGE):$(TAG)
IMAGE_LATEST := $(IMAGE):latest

.PHONY: build-image push-image create-box enter

build-image:
	podman build \
		--build-arg "USER_NAME=$$(whoami)" \
		--build-arg "USER_ID=$$(id -u)" \
		--build-arg "GROUP_ID=$$(id -g)" \
		--tag $(IMAGE_VERSIONED) \
		.

push-image: build-image
	podman push $(IMAGE_VERSIONED)
	podman tag $(IMAGE_VERSIONED) $(IMAGE_LATEST)
	podman push $(IMAGE_LATEST)
	
create-box:
	distrobox create --image $(IMAGE_VERSIONED) --name $(NAME) --yes

enter:
	distrobox enter $(NAME)

