#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

MACHINE=$1

DISK=${MACHINE}/linux.img

UUID=61CF84A9-E75E-4237-9D21-285EE98D114D
CPUS=1
MEMORY=1G

. ${MACHINE}/settings.ini

sudo xhyve \
    -A \
    -c ${CPUS} \
    -m ${MEMORY} \
    -s 0,hostbridge \
    -s 2,virtio-net \
    -s 4,virtio-blk,${DISK} \
    -s 31,lpc \
    -l com1,stdio \
    -U ${UUID} \
    -f "kexec,${MACHINE}/vmlinuz-linux,${MACHINE}/initramfs-linux.img,root=/dev/vda2 rw console=ttyS0"
