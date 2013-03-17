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

add() {
	[ -e "$1" ] || fail "The ldif file you specified was not found.\nPlease make sure you specified a valid file name."
	ldapadd -x -D $BIND_DN -w $LDAP_PASSWORD -f $1
  success "Added $1"
}

add-all() {
	# check if ldif files are present
	[ $(ls $BOOT/*.schema 2>/dev/null) ] || fail "No .ldif files where found.\nYou might want to place some files inside the \"content\" folder."

	info 'Adding ALL .ldif files ...'

	for $file in "$BOOT/*.ldif"
	do
		add $file
	done
}

##
# decide what to do :P
##

case "$1" in
  all)
    add-all
    ;;
  ldif)
    add $2
    ;;
  *)
    # if no parameters are given print which are available
    echo "Usage: $0 {all|ldif FILENAME}"
    exit 1
    ;;
esac
