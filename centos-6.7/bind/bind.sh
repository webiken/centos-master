#!/bin/bash
set -e

yum install bind bind-utils -y

mkdir -p /etc/named/zones

cat <<EOF >> /etc/named/named.conf.local
zone "burhaniya.sd" {
    type master;
    file "/etc/named/zones/db.burhaniya.sd"; # zone file path
};


zone "0.10.in-addr.arpa" {
    type master;
    file "/etc/named/zones/db.0.10";  # 10.0.0.0/24 subnet
};
EOF


cat <<EOF >> /etc/named/zones/db.burhaniya.sd
@       IN      SOA     master.burhaniya.sd master.burhaniya.sd. (
                              3         ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL

; name servers - NS records
    IN      NS      master.burhaniya.sd.

master.burhaniya.sd.       IN      A       10.0.0.10
ns1.burhaniya.sd.          IN      A       10.0.0.10
ns2.burhaniya.sd.          IN      A       10.0.0.11
EOF

cat <<EOF >> /etc/named/zones/db.0.10
$TTL    604800
@       IN      SOA     master.burhaniya.sd. master.burhaniya.sd. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; name servers - NS records
       IN      NS      master.burhaniya.sd.

10.0   IN      PTR     master.burhaniya.sd.    ; 10.0.0.10
10.0   IN      PTR     ns1.burhaniya.sd.    ; 10.0.0.10
11.0   IN      PTR     ns2.burhaniya.sd.    ; 10.0.0.11
EOF

cat <<EOF >> /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//

acl "trusted" {
        10.0.0.0/24;
};


options {
	listen-on port 53 { 127.0.0.1; 10.0.0.10; 10.0.0.11; };
	#listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { trusted; };
	recursion yes;

	dnssec-enable yes;
	dnssec-validation yes;
	dnssec-lookaside auto;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.iscdlv.key";

	managed-keys-directory "/var/named/dynamic";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};



include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
include "/etc/named/named.conf.local";
EOF