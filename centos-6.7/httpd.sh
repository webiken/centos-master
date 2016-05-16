yum -y install httpd
mkdir -p /var/www/html/ks

cat <<EOF >> /var/www/html/ks/default
install
url --url http://mirrors.sonic.net/centos/7.2.1511/os/x86_64/
lang en_US.UTF-8
keyboard us
timezone --utc America/New_York
network --noipv6 --onboot=yes --bootproto dhcp
authconfig --enableshadow --enablemd5
rootpw --iscrypted $6$saltsalt$qFmFH.bQmmtXzyBY0s9v7Oicd2z4XSIecDzlB5KiA2/jctKu9YterLp8wwnSq.qc.eoxqOmSuNp2xS0ktL3nh/
firewall --enabled --port 22:tcp
selinux --disabled
bootloader --location=mbr --driveorder=sda --append="crashkernel=auth rhgb"

# Disk Partitioning
clearpart --all --initlabel --drives=sda
part /boot --fstype=ext4 --size=200
part pv.1 --grow --size=1
volgroup vg1 --pesize=4096 pv.1

logvol / --fstype=ext4 --name=lv001 --vgname=vg1 --size=6000
logvol /var --fstype=ext4 --name=lv002 --vgname=vg1 --grow --size=1
logvol swap --name=lv003 --vgname=vg1 --size=2048
# END of Disk Partitioning

# Make sure we reboot into the new system when we are finished
reboot

# Package Selection
%packages --nobase --excludedocs
@core
-*firmware
-iscsi*
-fcoe*
-b43-openfwwf
kernel-firmware
-efibootmgr
wget
sudo
perl

%pre

%post --log=/root/install-post.log
(
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

# PLACE YOUR POST DIRECTIVES HERE
) 2>&1 >/root/install-post-sh.log
EOF
