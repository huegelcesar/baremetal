#!/usr/bin/env bash
../gcc-7.2.0/bin/arm-gcc -ffreestanding -Wall -Wextra -Werror \
						 -c src/start.c \
						 -o bin/start.o
