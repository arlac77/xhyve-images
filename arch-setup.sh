
fdisk /dev/vda << EOF >> /dev/null
g
n
1

+80M
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
EOF


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

cat >/mnt/etc/systemd/network/enp0s2.network <<EOF
[Match]
Name=enp0s2

[Network]
DHCP=yes
EOF

cat >/mnt/etc/resolv.conf <<EOF
nameserver 10.0.0.20
nameserver fd00::c225:6ff:fee2:8a78
search mf.de
EOF

arch-chroot /mnt
systemctl enable systemd-networkd
systemctl set-default multi-user.target

pacman -S openssh python
systemctl enable sshd

passwd

exit

systemctl start sshd

mkdir -p /root/.ssh
cat >/root/.ssh/authorized_keys<<EOF
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPzHP3wE8qlmB9QLwKMK5dIb/Azej+aIg6UmL6YRoHE51ISI4SQc6gBYCfucB9isVns/ucejDRdVQBtthZd/RTM= markus@pro
EOF


scp "root@192.168.64.7:/mnt/boot/*" .

ip link show dev enp0s2
ip link set enp0s2 up
ip address add 192.168.64.2/24 broadcast + dev enp0s2

ip route add 0/32 via 192.168.64.1 dev enp0s2

pacman -Syu
