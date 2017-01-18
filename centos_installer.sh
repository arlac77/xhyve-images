#!/bin/bash

# http://www.admin-magazin.de/Online-Artikel/CentOS-virtualisiert-in-Xhyve-auf-OS-X

VERSION=7.3.1611
ISO=CentOS-7-x86_64-Minimal-1611.iso
VOLUME="CentOS 7 x86_64"
DEST="centos-${VERSION}"
IMAGE_SIZE=6

if  [ -f ${ISO} ]
then
  echo "${ISO} schon da"
else
  curl -O http://centos.copahost.com/${VERSION}/isos/x86_64/${ISO}
fi


if  [ -f ${DEST}/vmlinuz ]
then
  echo "${DEST}/vmlinuz schon da"
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
  echo "${DEST}/hdd.img schon da"
else

  dd if=/dev/zero of=${DEST}/hdd.img bs=1g count=${IMAGE_SIZE}

  KERNEL="${DEST}/vmlinuz"
  INITRD="${DEST}/initrd.img"
  CMDLINE="earlyprintk=serial console=ttyS0 acpi=off"
  MEM="-m 1G"
  NET="-s 2:0,virtio-net"
  IMG_CD="-s 3,ahci-cd,${ISO}"
  IMG_HDD="-s 4,virtio-blk,${DEST}/hdd.img"
  PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
  LPC_DEV="-l com1,stdio"
  sudo xhyve $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD -f kexec,$KERNEL,$INITRD,"$CMDLINE"
fi
