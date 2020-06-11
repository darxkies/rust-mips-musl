FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl bash build-essential ca-certificates git gzip tar && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH=$PATH:/root/.cargo/bin

RUN rustup target install mipsel-unknown-linux-musl

ENV OPENSSL_STATIC=1 
ENV PKG_CONFIG_ALLOW_CROSS=true 
ENV PKG_CONFIG_ALL_STATIC=true 
ENV LIBZ_SYS_STATIC=1 
ENV OPENSSL_DIR=/workspace/compiler/mipsel-buildroot-linux-musl/sysroot/usr/ 
ENV LD_LIBRARY_PATH=/workspace/compiler/lib 
ENV TARGET=mipsel-unknown-linux-musl
ENV CC_mipsel_unknown_linux_musl=/workspace/compiler/bin/mipsel-buildroot-linux-musl-gcc 
ENV RUSTFLAGS='-C target-feature=+crt-static -C link-args=-static-libgcc -lz' 

RUN echo "[build]\ntarget = \"mipsel-unknown-linux-musl\"\n[target.mipsel-unknown-linux-musl]\nlinker = \"/workspace/compiler/bin/mipsel-buildroot-linux-musl-gcc\"" > /root/.cargo/config

RUN mkdir -p /workspace/compiler

COPY files/sdk.tar.gz /workspace/sdk.tar.gz

RUN tar xzfv /workspace/sdk.tar.gz -C /workspace/compiler 

ENV PATH=/workspace/compiler/bin:$PATH

WORKDIR /workspace/project
