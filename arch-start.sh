#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

MACHINE=$1

DISK=${MACHINE}/linux.img

UUID=61CF84A9-E75E-4237-9D21-285EE98D114D
CPUS=1
MEMORY=1G
MAC=42:22:b1:3b:bd:90
NET=virtio-net
#NET=virtio-tap

. ${MACHINE}/settings.ini

NET_PCI="-s 2,${NET},tap0,mac=${MAC}"

echo ${NET_PCI}

#exit

sudo xhyve \
    -A \
    -c ${CPUS} \
    -m ${MEMORY} \
    -s 0,hostbridge \
    ${NET_PCI} \
    -s 4,virtio-blk,${DISK} \
    -s 31,lpc \
    -l com1,stdio \
    -U ${UUID} \
    -f "kexec,${MACHINE}/vmlinuz-linux,${MACHINE}/initramfs-linux.img,root=/dev/vda2 rw console=ttyS0"
