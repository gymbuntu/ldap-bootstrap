#!/bin/bash
#
# ldap-bootstrap install ldap with all depencies
# it also adds a custom schema and some user content

# Ask for the administrator password upfront
sudo -v

BOOT="$(pwd)"

set -e

CONF="$BOOT/slapd.conf"

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

debconf() {
  sudo echo "slapd $1" | sudo debconf-set-selections
}

preconfigure() {
  debconf "slapd/allow_ldap_v2 boolean $LDAP_ALLOW_V2"
  debconf "slapd/password2 password $LDAP_PASSWORD"
  debconf "slapd/password1 password $LDAP_PASSWORD"
  debconf "slapd/domain string $LDAP_DOMAIN"
  debconf "shared/origanization string $LDAP_ORGANIZATION"
}


install() {
  info 'Installing slapd ...'

  preconfigure

  sudo apt-get install -y -q slapd ldap-utils >/dev/null
  success 'Installed slapd'

  # fail if no schema files are present
  [ $(ls $BOOT/schema/*.ldif 2>/dev/null) ] || fail "No schema files in \".ldif\" format where found\nI\'m sure you want to add some schema files.\nBe sure to convert your \".schema\" files first to \".ldif\" using the schema/convert.sh {file} tool."

  # add schema again
  info 'Adding schema files now ...'
  for file in $BOOT/schema/*.ldif
  do
    sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f $file
    success "Added schema $file"
  done

  info 'Currently activated schemas:'
  sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=schema,cn=config" "dn"

  # add content now
  info 'Adding Content now ...'

  for file in $BOOT/content/*.ldif
  do
      ldapadd -x -D $BIND_DN -w $LDAP_PASSWORD -f $file
      success "Added $file"
  done
}

remove() {
  info 'Removing (purging) slapd ...'

  sudo apt-get purge -y -q slapd ldap-utils >/dev/null
  success 'Removed slapd'

  info 'Removing addtional directories'
  DIRS=("/etc/ldap" "/var/lib/ldap" "/usr/lib/ldap")

  for dir in ${DIRS[@]}
  do
      if [ -d "$dir" ]
      then
          sudo rm -rf $dir
          success "Removed $dir"
      fi
  done
}

reconfigure() {
  info 'Reconfiguring slapd ...'
  remove
  install
}


##
# decide what to do :P
##

case "$1" in
  install)
    install
    ;;
  reconfigure)
    reconfigure
    ;;
  remove)
    remove
    ;;
  *)
    # if no parameters are given print which are available
    echo "Usage: $0 {install|reconfigure|remove}"
    exit 1
    ;;
esac