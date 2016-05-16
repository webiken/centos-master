yum install -y dhcp

IPADDR=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

cat <<EOF >> /etc/dhcp/dhcpd.conf
subnet 10.0.0.0 netmask 255.255.255.0 {
        option routers                  10.0.0.10;
        option subnet-mask              255.255.255.0;
        option domain-search            "burhaniya.sd";
        option domain-name-servers      8.8.8.8;
        option time-offset              -18000;     # Eastern Standard Time
	range 10.0.0.11 10.0.0.200;
}
allow booting;
allow bootp;
option option-128 code 128 = string;
option option-129 code 129 = text;
next-server $IPADDR; 
filename "/pxelinux.0";
EOF

service dhcpd restart