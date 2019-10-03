#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ -z Arch.img ]; then
    echo "missing Arch.img disk aborting"
    exit 1
fi

diskinfo=$(hdiutil attach Arch.img  | grep DOS_FAT_32 )

set +e
mkdir -p boot
mnt=$(echo "$diskinfo" | awk '{$1=$2=""; print $0}' | xargs)
cp "${mnt}/vmlinuz-linux" boot
cp "${mnt}/initramfs-linux.img" boot
set -e

disk=$(echo "$diskinfo" |  cut -d' ' -f1)
hdiutil eject "$disk"

sudo build/xhyve \
    -A \
    -c 1 \
    -m 1G \
    -s 0,hostbridge \
    -s 2,virtio-net \
    -s 4,virtio-blk,Arch.img \
    -s 31,lpc \
    -l com1,stdio \
    -f "kexec,boot/vmlinuz-linux,boot/initramfs-linux.img,root=/dev/vda2 rw console=ttyS0"