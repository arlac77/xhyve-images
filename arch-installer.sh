#!/bin/bash
#
# Usage 
# install-arch.sh ./archlinux-2018.11.01-x86_64.iso

# first you neeed to patch xhyve with this 
# index 61aeebb..39a9c4b 100644
# --- a/src/firmware/kexec.c
# +++ b/src/firmware/kexec.c
# @@ -185,6 +185,7 @@ kexec_load_ramdisk(char *path) {
#         fseek(f, 0, SEEK_SET);
#
#         ramdisk_start = ALIGNUP((kernel.base + kernel.size), 0x1000ull);
# + ramdisk_start += (uint32_t) 16777216;
#
#         if ((ramdisk_start + sz) > memory.size) {
#                 /* not enough memory */
#
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
# boot your Arch install using start-arch.sh
#
# take a snapshot if needed tmutil localsnapshot
#
# sudo needed if you want virtio-net

DISK_SIZE=6G

set -euo pipefail
IFS=$'\n\t'

if [ -z "$1" ]; then
    echo "missing path to iso"
    exit 1
fi

if [ -f Arch.img ]; then
    echo "existing Arch.img disk aborting"
    exit 1
fi

echo "creating a ${DISK_SIZE} disk"
mkfile -n ${DISK_SIZE} Arch.img

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
    -c "1" \
    -m "1G" \
    -s 0,hostbridge \
    -s 2,virtio-net \
    -s "3,ahci-cd,$1" \
    -s 4,virtio-blk,Arch.img \
    -s 31,lpc \
    -l com1,stdio \
    -f "kexec,boot/vmlinuz,boot/archiso.img,archisobasedir=arch archisolabel=$label console=ttyS0"

# fdisk /dev/vda
# g
# n 1 +300M
# n 2 -512M
# n 3 

# mkfs.fat -F32 /dev/vda1
# mkfs.ext4  /dev/vda2
# mkswap /dev/vda3
# swapon /dev/vda3

# mount /dev/vda2 /mnt
# mount /dev/vda1 /mnt/boot
# pacstrap /mnt base
# genfstab -U /mnt >> /mnt/etc/fstab
# arch-chroot /mnt
# passwd
# exit