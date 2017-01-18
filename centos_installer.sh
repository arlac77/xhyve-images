VERSION=7.3.1611
ISO=CentOS-7-x86_64-Minimal-1611.iso
VOLUME="CentOS 7 x86_64"
DEST="centos-${VERSION}"

if  [ -f ${ISO} ] ; then
  curl -O http://centos.copahost.com/${VERSION}/isos/x86_64/${ISO}
fi


exit

dd if=/dev/zero bs=2k count=1 of=installer.iso
dd if=${ISO} bs=2k skip=1 >>installer.iso

hdiutil attach installer.iso

mkdir -p ${DEST}
cp "/Volumes/${VOLUME}/isolinux/vmlinuz"    ${DEST}
cp "/Volumes/${VOLUME}/isolinux/initrd.img" ${DEST}

diskutil unmount "/Volumes/${VOLUME}"

rm installer.iso
