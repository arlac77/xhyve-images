#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

MACHINE=$1

DISK=${MACHINE}/linux.img

echo $DISK

sudo xhyve \
    -A \
    -c 4 \
    -m 8G \
    -s 0,hostbridge \
    -s 2,virtio-net \
    -s 4,virtio-blk,${DISK} \
    -s 31,lpc \
    -l com1,stdio \
    -f "kexec,${MACHINE}/vmlinuz-linux,${MACHINE}/initramfs-linux.img,root=/dev/vda2 rw console=ttyS0"
