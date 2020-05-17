FROM ubuntu:18.04

ARG BUILDROOT_VERSION_ARGUMENT

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q bash binutils build-essential bzip2 ca-certificates cpio debianutils file g++ gcc git graphviz gzip libncurses5-dev locales make patch perl python rsync sed tar wget vim bzr cvs mercurial subversion unzip bc && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV BUILDROOT_VERSION=${BUILDROOT_VERSION_ARGUMENT:-2020.02.2}

ENV FORCE_UNSAFE_CONFIGURE=1

RUN cd / && wget -nv https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz 

WORKDIR /workspace
