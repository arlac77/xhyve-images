#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

MACHINE=$1

DISK1=${MACHINE}/linux.img
DISK2=""

UUID=61CF84A9-E75E-4237-9D21-285EE98D114D
CPUS=1
MEMORY=1G
MAC=42:22:b1:3b:bd:90
NET=virtio-net
#NET=virtio-tap

. ${MACHINE}/settings.ini

NET_OPTIONS="-s 2,${NET},tap0,mac=${MAC}"

DISK_OPTIONS="-s 4,virtio-blk,${DISK1}"

if [ "${DISK2}" != "" ]
then
  DISK_OPTIONS+=" -s 5,virtio-blk,${DISK2}"
fi

sudo xhyve \
    -A \
    -c ${CPUS} \
    -m ${MEMORY} \
    -s 0,hostbridge \
    ${NET_OPTIONS} \
    ${DISK_OPTIONS} \
    -s 31,lpc \
    -l com1,stdio \
    -U ${UUID} \
    -f "kexec,${MACHINE}/vmlinuz-linux,${MACHINE}/initramfs-linux.img,root=/dev/vda2 rw console=ttyS0"
