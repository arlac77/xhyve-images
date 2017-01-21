#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use text mode install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts=''
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --nameserver=8.8.8.8 --ipv6=auto --activate
network  --hostname=centos

# Root password
rootpw --iscrypted $6$NbWiWTuXcaKfINTv$dBS3wHrzqMHrz8pzi/2rdy2Son5575L1QC0EpMfOZVfaUVi/1lQv/04758tA3sJDJC6uayulje7K6Dr8KEf631
# System services
services --enabled="chronyd"
# Do not configure the X Window System
skipx
# System timezone
timezone Europe/Berlin --isUtc
user --name=build --password=$6$rye7OcsPfyEo8N6X$VcP3M/FzolkfB7NFnpPijf68t8bbIRSMNA6.k7OjaY2c1baJSLu0pA3maJRSVUzc/.r3PHxJbVxDCAwQaqy3/. --iscrypted --gecos="build"
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=plain
# Partition clearing information
clearpart --all --initlabel --drives=vda

%packages
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end

