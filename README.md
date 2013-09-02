# Gymhaan – LDAP Boostrap

Use LDAP Bootstrap to power up your *Ubuntu 13.04* LDAP Server painlessly.
Easy to use and blazing fast setup are our aims.

## Install

Clone this Repo to your desired *Ubuntu 13.04* machine, then let's go.

```sh
git clone https://github.com/gymbuntu/ldap-bootstrap ~/ldap-bootstrap
```

## Configuration

### slapd.conf

Edit the `slapd.conf` file which defines all your ldap settings.

### The schema

The `gymhaan.schema` files which can be found in `schema/gymhaan.schema` defines our basic structure.

Feel free to edit this file to your needs.

### The content

Inside the `/content` folder you'll find all the default content which will be added to your ldap-server by default. We have included some really useful stuff like default groups and so on.

Here's the full list of all content that will be added

* 00_core.ldif – really basic structural objects for people and groups
* 01_groups.ldif – the groups matching our schema file
* 02_manager.ldif – a manager user for daily usage (like an admin, but can be disabled if needed)
* 03_crow.ldif – our super cool manager that is like our "admin" but is in fact a real ldap user
* 04_guest.ldif – our guest account that can / will be used for the Ubuntu Guest feature
* 05_fh.ldif – this represents my own chef account
* 06_rs.ldif – this is the super cool Roland Stiebel's chef account

## Usage

Cd into the ldap-bootstrap repo you just cloned like so

```sh
cd ~/ldap-bootstrap
```

### Using our schema

To use our schema, you'll need to cd into the `/schema` folder and need to one of the following commands

Convert one file only.

```sh
./convert.sh gymhaan.schema
```

Or convert all files by running.
```sh
./convert.sh
```

### Using our content

All files placed inside `/content/` will be added by default when running our main script `slapd.sh`, but you can also manually add content like so.

```sh
/content/add.sh 05_fh.ldif
```

### Using the main script

To use our main script `slapd.sh` you'll need to convert your schema files at first. If you haven't done so, return to the "Using our schema" section and then continue.

If you have successfully configured the `slapd.conf` file and also converted all schema files, you can install the ldap server using the following commands.

```sh
./slapd.sh install
```

To reinstall the whole server and reset all settings, simply use the `reconfigure` command.

```sh
./slapd.sh reconfigure
```

## Thanks

Thanks to Roland Stiebel with whom I did this whole project. We hope this whole thing will help some people getting their ldap server up and running without struggling too much with all the f***ed up console shit.

A project by @fharbe