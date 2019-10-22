#!/usr/bin/env bash
../gcc-7.2.0/bin/arm-ld -T src/linker.ld bin/_start.o bin/start.o \
					    -o bin/kernel.elf