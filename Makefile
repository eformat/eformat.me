# Image URL to use all building/pushing image targets
REGISTRY ?= quay.io
REPOSITORY ?= $(REGISTRY)/eformat/eformat-me

IMG := $(REPOSITORY):latest

# Build the oci image
podman-build:
	podman build . -t ${IMG} -f Dockerfile

# Push the oci image
podman-push: podman-build
	podman push ${IMG}
