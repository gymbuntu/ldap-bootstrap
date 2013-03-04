#!/bin/bash

# exit if no param is specified
[ -z "$1" ] && exit 0
# specify the base name as schema name
# SCHEMA="${1%.*}"
# set ldif file name
# SCHEMA_LDIF="$(pwd)/cn=$SCHEMA.ldif"
SCHEMA_LDIF=$1

ldapadd -Q -Y EXTERNAL -H ldapi:/// -f $SCHEMA_LDIF
echo "Added schema to the ldap server"

ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=schema,cn=config" "dn"
