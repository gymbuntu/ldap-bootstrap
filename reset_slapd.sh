#!/bin/bash

SCHEMA="gymhaan.schema"

LDAP_ALLOW_V2="false"
LDAP_DOMAIN="gymhaan.local"
LDAP_ORGANIZATION="gymhaan"
LDAP_PASSWORD="ldappasswd"

echo "Removing (purge) slapd ..."
apt-get purge -y -q slapd >/dev/null
echo "Removing additional dirs ..."

DIRS=("/etc/ldap" "/var/lib/ldap" "/usr/lib/ldap")

for dir in ${DIRS[@]}
do
    if [ -d $dir ]
    then
        rm -rf $dir
        echo "-> Removed $dir"
    fi
done

echo "slapd slapd/allow_ldap_v2 boolean $LDAP_ALLOW_V2" | debconf-set-selections
echo "slapd slapd/password2 password $LDAP_PASSWORD" | debconf-set-selections
echo "slapd slapd/password1 password $LDAP_PASSWORD" | debconf-set-selections
echo "slapd slapd/domain string $LDAP_DOMAIN" | debconf-set-selections
echo "slapd shared/origanization string $LDAP_ORGANIZATION" | debconf-set-selections

echo "Installing slapd again ..."
apt-get install -y -q slapd >/dev/null

# add schema again
echo "Adding schema $SCHEMA now ..."
ldapadd -Q -Y EXTERNAL -H ldapi:/// -f $(pwd)/schema/cn=gymhaan.ldif

echo "-> active schema files:"
ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=schema,cn=config" "dn"

# add content now

echo "Adding LDIF files ..."
BIND_DN="cn=admin,dc=gymhaan,dc=local"

for file in $(pwd)/content/*.ldif
do
    echo "-> Adding $file ..."
    ldapadd -x -D $BIND_DN -w $LDAP_PASSWORD -f $file
done

