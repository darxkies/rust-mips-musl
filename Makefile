BUILDROOT_VERSION = 2020.02.2
BUILDROOT_IMAGE_NAME = darxkies/buildroot:$(BUILDROOT_VERSION)
MIPS_IMAGE_NAME = darxkies/mips:$(BUILDROOT_VERSION)
MIPS_SDK_CONTAINER = docker run -ti -v $$(pwd)/buildroot/mips/config:/config -v $$(pwd)/buildroot/mips/data:/workspace $(BUILDROOT_IMAGE_NAME) 
MIPS_CONTAINER = docker run -ti --rm -v $$(pwd):/workspace/project -v $$(pwd)/target/registry:/root/.cargo/registry $(MIPS_IMAGE_NAME)

build: mips-build mips-compile

buildroot:
	docker build --build-arg BUILDROOT_VERSION_ARGUMENT=$(BUILDROOT_VERSION) -t $(BUILDROOT_IMAGE_NAME) docker/buildroot

mips-sdk-build: buildroot
	$(MIPS_SDK_CONTAINER) /config/build.sh sdk
	mkdir -p docker/mips/files
	(cd buildroot/mips/data/compiler && tar czfv ../../../../docker/mips/files/sdk.tar.gz .)

mips-sdk-menuconfig: buildroot
	$(MIPS_SDK_CONTAINER) /config/build.sh menuconfig

mips-sdk-shell: buildroot
	$(MIPS_SDK_CONTAINER)

mips-sdk-clean: 
	sudo rm -Rf buildroot/mips/data

mips-build: mips-sdk-build
	docker build -t $(MIPS_IMAGE_NAME) docker/mips 

mips-shell: 
	$(MIPS_CONTAINER) /bin/bash

mips-compile: 
	$(MIPS_CONTAINER) cargo build --release

.PHONY: buildroot
