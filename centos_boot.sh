#!/bin/bash


VERSION=7.3.1611
ISO=CentOS-7-x86_64-Minimal-1611.iso
VOLUME="CentOS 7 x86_64"
DEST="centos-${VERSION}"

KERNEL="${DEST}/vmlinuz-3.10.0-514.el7.x86_64"
INITRD="${DEST}/initramfs-3.10.0-514.el7.x86_64.img"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off root=/dev/vda3 ro"
MEM="-m 2G"
SMP="-c 2"
NET="-s 2:0,virtio-net"
#IMG_CD="-s 3,ahci-cd,${ISO}"
IMG_HDD="-s 4,virtio-blk,${DEST}/hdd.img"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
#ACPI="-A"
UUID="-U 61CF84A9-E75E-4237-9D21-285EE98D114D"
LPC_DEV="-l com1,stdio"
sudo xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
