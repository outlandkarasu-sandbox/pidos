#!/bin/sh

ldc2 -mtriple=arm-none-linux-eabi -mcpu=cortex-a7 -betterC -c start.d 
arm-none-eabi-ld -T link.ld --gc-sections start.o -o kernel.elf
arm-none-eabi-objcopy kernel.elf -O binary kernel.img
