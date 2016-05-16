IPADDR=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
tftpboot='/var/lib/tftp'
mkdir -p $tftpboot/pxelinux.cfg
mkdir -p $tftpboot/images/centos/x86_64/7

yum -y install tftp-server syslinux

sed -i "s/disable = yes/disable = no/g" /etc/xinetd.d/tftp

cp /usr/share/syslinux/pxelinux.0 $tftpboot
cp /usr/share/syslinux/menu.c32 $tftpboot
cp /usr/share/syslinux/memdisk $tftpboot
cp /usr/share/syslinux/mboot.c32 $tftpboot
cp /usr/share/syslinux/chain.c32 $tftpboot


cat <<EOF >> $tftpboot/pxelinux.cfg/default
default menu.c32
prompt 0
timeout 300
ONTIMEOUT local
MENU TITLE PXE Menu

LABEL CentOS 7.2 x86 NO KS eth0
        MENU LABEL CentOS 7.2
        KERNEL images/centos/x86_64/7/vmlinuz
        APPEND ks=http://10.0.0.10/ks/default initrd=images/centos/x86_64/7/initrd.img ramdisk_size=100000
EOF

chkconfig tftp on
service xinetd restart
