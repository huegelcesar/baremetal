#!/usr/bin/env bash
../gcc-7.2.0/bin/arm-as -march=armv7-a \
						-mcpu=cortex-a15 \
						src/_start.arm \
						-o bin/_start.o
