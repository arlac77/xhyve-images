

fdisk /dev/vda << __EOF__ >> /dev/null
g
n
1

+200M
t
1

n
2

-512M
t
2
22

n
3


t
3
19

w
__EOF__


mkfs.fat -F32 /dev/vda1
mkfs.ext4  /dev/vda2
mkswap /dev/vda3
swapon /dev/vda3

mount /dev/vda2 /mnt
#mount /dev/vda1 /mnt/boot

# pacstrap /mnt base
# genfstab -U /mnt >> /mnt/etc/fstab
# arch-chroot /mnt
# passwd
# exit