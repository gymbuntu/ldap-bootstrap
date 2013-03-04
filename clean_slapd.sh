#!/bin/bash

echo "Purging slapd!"
apt-get purge --quiet slapd

DIRS=("/etc/ldap" "/var/lib/ldap" "/usr/lib/ldap")

for dir in ${DIRS[@]}
do
    if [ -d $dir ]
    then
        rm -rf $dir
        echo "Removed $dir"
    fi
done

echo "Installing Slapd again"
apt-get install --quiet slapd

echo "Reconfigure Slapd!"
dpkg-reconfigure slapd
