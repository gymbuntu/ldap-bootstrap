#!/bin/bash

# you must specify the bind_dn
# [ -z "$1" ] && exit 0
# BIND_DN="$1"
BIND_DN="cn=admin,dc=gymhaan,dc=local"


if [ -z "$1" ]
then
for file in $(pwd)/*.ldif
do
    ldapadd -x -D $BIND_DN -W -f $file
    echo "Added $file"
done
else
ldapadd -x -D $BIND_DN -W -f $1
echo "Added $1"
fi
