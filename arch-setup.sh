

fdisk /dev/vda << __EOF__ >> /dev/null
g
n
1

+100M
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
mkfs.ext4 /dev/vda2
mkswap /dev/vda3
swapon /dev/vda3

mount /dev/vda2 /mnt
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

sed -i 's/^MODULES=\(.*\)/MODULES=\(virtio_blk\)/' /etc/mkinitcpio.conf

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

mkdir -p /mnt/root/.ssh
cat >/mnt/root/.ssh/authorized_keys<<EOF
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPzHP3wE8qlmB9QLwKMK5dIb/Azej+aIg6UmL6YRoHE51ISI4SQc6gBYCfucB9isVns/ucejDRdVQBtthZd/RTM= markus@pro
EOF

arch-chroot /mnt
passwd
exit

ifconfig -a
systemctl start sshd
