#!/bin/bash

# exit if no param specified
[ -z "$1" ] && exit 0
# specify the base name as schema name
SCHEMA="${1%.*}"

# the output dir for the schema ldif stuff
OUTPUT="/tmp/ldif_output"
# our schema base
# there should be no need to edit it
# it's taken from help.ubuntu.com
SCHEMA_BASE="$(pwd)/schema_base.conf"
# the new schema for the convertion
SCHEMA_CONVERT="/tmp/schema_convert.conf"


# delete the old schema convert file if there
[ -f $SCHEMA_CONVERT ] && rm $SCHEMA_CONVERT
cp $SCHEMA_BASE $SCHEMA_CONVERT
# the new schema file (should be place in /etc/ldap/schema)
SCHEMA_FILE="/etc/ldap/schema/$SCHEMA.schema"
# add our new schema to the base schema file
echo "include $SCHEMA_FILE" >> $SCHEMA_CONVERT
echo "Created Schema Convert file: $SCHEMA_CONVERT"

# copy the schema to /etc/ldap/schema
[ -f $SCHEMA_FILE ] && rm $SCHEMA_FILE
cp "$(pwd)/$SCHEMA.schema" $SCHEMA_FILE
echo "Copied Schema file to $SCHEMA_FILE"

# create the new output dir
[ -d $OUTPUT ] && rm -rf $OUTPUT
mkdir $OUTPUT
echo "Created Temporary Output Dir: $OUTPUT"

# get the schema index
SCHEMA_INDEX=$(slapcat -f $SCHEMA_CONVERT -F $OUTPUT -n0 | grep "$SCHEMA,cn=schema,cn=config")
SCHEMA_INDEX=${SCHEMA_INDEX:4}
echo "Created Schema Index: $SCHEMA_INDEX"

# create the new ldif file
SCHEMA_LDIF="$(pwd)/cn=$SCHEMA.ldif"
[ -f $SCHEMA_LDIF ] && rm $SCHEMA_LDIF
slapcat -f $SCHEMA_CONVERT -F $OUTPUT -n0 -H "ldap:///$SCHEMA_INDEX" -l $SCHEMA_LDIF
echo "Created new LDIF file $SCHEMA_LDIF"
echo "Please edit \"${SCHEMA_INDEX%$SCHEMA*}$SCHEMA\""
echo "to look like \"cn=$SCHEMA\""
echo "Also remove the lines beginning with"
echo "\"structuralObjectClass: olcSchemaConfig \"(all lines)!"
