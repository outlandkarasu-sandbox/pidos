#!/bin/sh

qemu-system-arm \
  -M raspi2 \
  -cpu arm1176 \
  -m 256 \
  -nographic \
  -kernel kernel.elf
