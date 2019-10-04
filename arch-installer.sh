#!/bin/bash
#
# Usage 
# arch-install.sh ./archlinux-2018.11.01-x86_64.iso

#
# perform normal Arch installation the hard drive is located at /dev/vda
# create a /boot /dev/vda1 of type vfat (type W95 FAT b)
# and your / in /dev/vda2
#
# add the virtio_blk to /etc/mkinitcpio.conf
# MODULES=(virtio_blk)
# 
# and run mkinitcpio -p linux
#
# no need to install a bootloader
#
#
# take a snapshot if needed tmutil localsnapshot
#

DISK_SIZE=6G
DISK_IMAGE=linux.img
UUID=61CF84A9-E75E-4237-9D21-285EE98D114D
CPUS=1
MEMORY=2G

set -euo pipefail
IFS=$'\n\t'

if [ -z "$1" ]; then
    echo "missing path to iso"
    exit 1
fi

if [ -f ${DISK_IMAGE} ]; then
    echo "existing ${DISK} disk aborting"
    exit 1
fi

echo "creating a ${DISK_SIZE} ${DISK_IMAGE}"
mkfile -n ${DISK_SIZE} ${DISK_IMAGE}

dd if=/dev/zero of=tmp.iso bs=$[4*1024] count=1
dd if="$1" bs=$[4*1024] skip=1 >> tmp.iso

diskinfo=$(hdiutil attach tmp.iso)

set +e
mkdir -p boot
mnt=$(echo "$diskinfo" | perl -ne '/(\/Volumes.*)/ and print $1')
cp "$mnt/arch/boot/x86_64/vmlinuz" boot
cp "$mnt/arch/boot/x86_64/archiso.img" boot
set -e

label=$(basename $mnt)

disk=$(echo "$diskinfo" |  cut -d' ' -f1)
hdiutil eject "$disk"
rm tmp.iso

sudo xhyve \
    -A \
    -c 1 \
    -m 2G \
    -s 0,hostbridge \
    -s 2,virtio-net \
    -s "3,ahci-cd,$1" \
    -s 4,virtio-blk,${DISK_IMAGE} \
    -s 31,lpc \
    -l com1,stdio \
    -f "kexec,boot/vmlinuz,boot/archiso.img,archisobasedir=arch archisolabel=$label console=ttyS0"
