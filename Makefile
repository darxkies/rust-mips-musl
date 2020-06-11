BUILDROOT_VERSION = 2020.02.3
BUILDROOT_IMAGE = darxkies/buildroot:$(BUILDROOT_VERSION)
BUILDROOT_CONTAINER = docker run -ti -v $$(pwd)/buildroot/mips-musl/config:/config -v $$(pwd)/buildroot/mips-musl/data:/workspace $(BUILDROOT_IMAGE) 
RUST_MIPS_MUSL_VERSION = $(BUILDROOT_VERSION).1
RUST_MIPS_MUSL_IMAGE = darxkies/rust-mips-musl:$(RUST_MIPS_MUSL_VERSION)
RUST_MIPS_MUSL_CONTAINER = docker run -ti --rm -v $$(pwd):/workspace/project -v $$(pwd)/target/registry:/root/.cargo/registry $(RUST_MIPS_MUSL_IMAGE)

build: rust-mips-musl-build compile

# Buildroot
buildroot-build:
	docker build --build-arg BUILDROOT_VERSION_ARGUMENT=$(BUILDROOT_VERSION) -t $(BUILDROOT_IMAGE) docker/buildroot

buildroot-clean: 
	sudo rm -Rf buildroot/mips-musl/data

buildroot-shell: buildroot-build
	$(BUILDROOT_CONTAINER)

buildroot-menuconfig: buildroot-build
	$(BUILDROOT_CONTAINER) /config/build.sh menuconfig

# Rust Mips Musl
rust-mips-musl-build: buildroot-build
	$(BUILDROOT_CONTAINER) /config/build.sh sdk
	mkdir -p docker/rust-mips-musl/files
	(cd buildroot/mips-musl/data/compiler && tar czfv ../../../../docker/rust-mips-musl/files/sdk.tar.gz .)
	docker build -t $(RUST_MIPS_MUSL_IMAGE) docker/rust-mips-musl 

rust-mips-musl-push: rust-mips-musl-build
	docker push $(RUST_MIPS_MUSL_IMAGE) 

rust-mips-musl-shell: 
	$(RUST_MIPS_MUSL_CONTAINER) /bin/bash

# Rust Compiler
compile: 
	$(RUST_MIPS_MUSL_CONTAINER) cargo build --release

.PHONY: buildroot
