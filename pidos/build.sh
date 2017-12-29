#!/bin/sh

arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -c boot.S -o boot.o
#arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra
ldc2 -mtriple=arm-none-linux-eabi -mcpu=arm1176jzf-s -betterC -c kernel.d 
arm-none-eabi-gcc -T linker.ld -o pidos.elf -ffreestanding -O2 -nostdlib boot.o kernel.o

#arm-none-eabi-objcopy pidos.elf -O binary pidos.img
