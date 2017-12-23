#!/bin/sh

ldc2 -mtriple=arm-none-linux-eabi -mcpu=cortex-a53 -betterC -c main.d
