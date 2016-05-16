#!/bin/bash
set -e

mkdir -p /var/www/html/centos7
mkdir -p /mtn/centos7

mount -o loop /root/CentOS-7-x86_64-DVD-1511.iso /mnt/centos7
cd /mnt/centos7
tar cvf - . | (cd /var/www/html/centos7; tar xvf -)
cd /; umount /mnt/centos7

cd /etc/yum.repo.d

cat <<EOF >> centos7.repo
[centos7]
name=centos7
baseurl=file:///var/www/html/centos7/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

yum clean all
yum install -y createrepo
createrepo /var/www/html/centos7
yum clean all
yum repolist all
