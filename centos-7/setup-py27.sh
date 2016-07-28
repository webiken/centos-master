#! /usr/bin/env bash

# Update the sources list
yum -y update
yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel xz-libs gcc g++ make wget

# Install Python 2.7.8
curl -o /root/Python-2.7.9.tar.xz https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz
tar -xf /root/Python-2.7.9.tar.xz -C /root
cd /root/Python-2.7.9 && ./configure --prefix=/usr/local && make && make altinstall

# Copy the application folder inside the container
ADD . /opt/iws_project

# Download Setuptools and install pip and virtualenv
wget https://bootstrap.pypa.io/ez_setup.py -O - | /usr/local/bin/python2.7
/usr/local/bin/easy_install-2.7 pip
/usr/local/bin/pip2.7 install virtualenv

