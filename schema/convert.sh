#!/bin/bash
#
# ldap-bootstrap install ldap with all depencies
# it also adds a custom schema and some user content

# Ask for the administrator password upfront
sudo -v

BOOT="$(pwd)"

set -e

CONF="$BOOT/../slapd.conf"

# load the config file
[ -e "$CONF" ] || fail "Config file \"$CONF\" not found!"
source $CONF

##
# useful functions
##

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

info () {
  printf "  [ \033[00;34m..\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

##
# the main script
##

convert-schema() {
	# our schema base
	# there should be no need to edit it
	# it's taken from help.ubuntu.com
	SCHEMA_BASE="$BOOT/schema_base.conf"

	# the new schema for the convertion
	SCHEMA_CONVERT="/tmp/schema_convert.conf"

	# delete the old schema convert file if there
	if [ -e "$SCHEMA_CONVERT" ]
	then
		sudo rm $SCHEMA_CONVERT
		success "Had to remove old convert schema"
	fi

	sudo cp $SCHEMA_BASE $SCHEMA_CONVERT
}

add-schema() {
	SCHEMA_TO="/etc/ldap/schema/$1.schema"

	# check if old schema exists
	if [ -e "$SCHEMA_TO" ]
	then
		sudo rm $SCHEMA_TO
		success "Had to remove old $SCHEMA_TO"
	fi

	sudo cp "$BOOT/$1.schema" $SCHEMA_TO
	success "Copied $1.schema to $SCHEMA_TO"

	# add our new schema to the base schema file
	sudo sh -c "echo \"include $SCHEMA_TO\" >> $SCHEMA_CONVERT"
	success "Added $(basename $SCHEMA_TO) to the convert schema"
}

schema-index() {
	# get the schema index
	SCHEMA_INDEX=$(sudo sh -c "slapcat -f $SCHEMA_CONVERT -F $OUTPUT -n0 | grep \"$1,cn=schema,cn=config\"")
	echo "${SCHEMA_INDEX:4}"
}

convert() {
	[ -e "$1" ] || fail "The ldif file you specified was not found.\nPlease make sure you specified a valid file name."

	# the output dir (temporary)
	OUTPUT="/tmp/ldif-output"
	if [ -d "$OUTPUT" ]
	then
		sudo rm -rf $OUTPUT
		success "Had to remove old output directory"
	fi
	#create the output directory
	sudo mkdir $OUTPUT

        #the schema basename ... (no extension)
	SCHEMA="$(basename ${1%.*})"
	convert-schema
	# add the schema to the convert schema
	add-schema $SCHEMA

	SCHEMA_INDEX=$(schema-index $SCHEMA)

	SCHEMA_LDIF="$BOOT/cn=$SCHEMA.ldif"
	if [ -e $SCHEMA_LDIF ]
	then
		sudo rm $SCHEMA_LDIF
		success "Had to remove old ldif file $(basename $SCHEMA_LDIF)"
	fi

	sudo slapcat -f $SCHEMA_CONVERT -F $OUTPUT -n0 -H "ldap:///$SCHEMA_INDEX" -l $SCHEMA_LDIF
	sudo chown $USER:$USER $SCHEMA_LDIF

	# fix the ldif file
	# remove the schema index in the file
	SCHEMA_SEARCH=${SCHEMA_INDEX%%,*}
	sed -i "s/${SCHEMA_SEARCH:3}/$SCHEMA/g" $SCHEMA_LDIF
	# remove the last 8 lines from the ldif file
	head -n -8 $SCHEMA_LDIF > "/tmp/cn=$SCHEMA.ldif"
	# overwrite the old ldif file
	rm $SCHEMA_LDIF && cp "/tmp/cn=$SCHEMA.ldif" $SCHEMA_LDIF
	success "Converted $(basename $1) to $(basename $SCHEMA_LDIF)"
}

convert-all() {
	# check if schema files are present
	[ "$(ls $BOOT/*.schema 2>/dev/null)" ] || fail "No .schema files where found.\nYou might want to place some files inside the \"schema\" folder."

	info 'Converting ALL .schema files ...'

	for file in "$BOOT/*.schema"
	do
		convert $file
	done
}

##
# decide what to do :P
##

[ -n "$1" ] || convert-all
if [ -e "$1" ]
then
    convert $1
else
    fail "The schema file you specified was not found!."
fi
