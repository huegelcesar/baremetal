#!/usr/bin/env bash
qemu-system-arm -M vexpress-a15 -cpu cortex-a15 -kernel bin/kernel.elf -nographic