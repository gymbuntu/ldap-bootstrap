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

delete() {
	[ -n "$1" ] || fail "The CN you specified was not found.\nPlease make sure you specify a valid DN."
	ldapdelete -x -D $BIND_DN -w $LDAP_PASSWORD $1
  success "Delete $1"
}

##
# decide what to do :P
##

delete "$1"
