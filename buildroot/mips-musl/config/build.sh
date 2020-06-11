#!/bin/bash

if [ ! -f /workspace/.config ]; then 
  tar xzfv /buildroot-${BUILDROOT_VERSION}.tar.gz -C /workspace/
  cp /config/.config /workspace/buildroot-${BUILDROOT_VERSION}/.config
fi

(cd /workspace/buildroot-${BUILDROOT_VERSION}/ && make $1)

echo "$1"

if [[ "menuconfig" -eq $1 ]]; then
  cp /workspace/buildroot-${BUILDROOT_VERSION}/.config /config/.config 
fi
