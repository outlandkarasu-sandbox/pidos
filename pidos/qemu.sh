#!/bin/sh

qemu-system-arm \
  -M versatilepb \
  -cpu arm1176 \
  -m 256 \
  -nographic \
  -kernel kernel.img
