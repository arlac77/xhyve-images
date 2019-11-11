#!/bin/bash

# http://www.admin-magazin.de/Online-Artikel/CentOS-virtualisiert-in-Xhyve-auf-OS-X
# https://www.notfound.me/archives/18

MAYOR=8
MINOR=1905
VERSION=${MAYOR}.0.${MINOR}
ISO=CentOS-${MAYOR}-x86_64-${MINOR}-dvd1.iso
VOLUME="CentOS-${MAYOR}-BaseOS-"
DEST="centos-${VERSION}"
IMAGE_SIZE=8

if  [ -f ${ISO} ]
then
  echo "${ISO} already there"
else
  curl -O http://mirror.infonline.de/centos/${VERSION}/isos/x86_64/${ISO}
fi


if  [ -f ${DEST}/vmlinuz ]
then
  echo "${DEST}/vmlinuz already there"
else
  dd if=/dev/zero bs=2k count=1 of=installer.iso
  dd if=${ISO} bs=2k skip=1 >>installer.iso

  hdiutil attach installer.iso

  mkdir -p ${DEST}
  cp "/Volumes/${VOLUME}/isolinux/vmlinuz"    ${DEST}
  cp "/Volumes/${VOLUME}/isolinux/initrd.img" ${DEST}

  diskutil unmount "/Volumes/${VOLUME}"

  rm installer.iso
fi


if  [ -f ${DEST}/hdd.img ]
then
  echo "${DEST}/hdd.img already there"
else
  dd if=/dev/zero of=${DEST}/hdd.img bs=1g count=${IMAGE_SIZE}
fi

KERNEL="${DEST}/vmlinuz"
INITRD="${DEST}/initrd.img"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off"
MEM="-m 2G"
NET="-s 2:0,virtio-net"
IMG_CD="-s 3,ahci-cd,${ISO}"
IMG_HDD="-s 4,virtio-blk,${DEST}/hdd.img"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
sudo xhyve $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD -f kexec,$KERNEL,$INITRD,"$CMDLINE"


## cd /mnt/sysimage/boot/
## python -m SimpleHTTPServer

# curl -O 192.168.64.7:8000/vmlinuz-3.10.0-514.el7.x86_64
# curl -O 192.168.64.7:8000/initramfs-3.10.0-514.el7.x86_64.img
