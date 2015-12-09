#!/usr/bin/env bash
#
# This script installs puppet 3.x or 4.x and deploy the manifest using puppet apply -e "include bussmtp"
#
# Usage:
# Ubuntu / Debian: wget https://raw.githubusercontent.com/pgomersbach/bussmtp/master/files/bootme.sh; bash bootme.sh
#
# Red Hat / CentOS: curl https://raw.githubusercontent.com/pgomersbach/bussmtp/master/skeleton/files/bootme.sh -o bootme.sh; bash bootme.sh
# Options: add 3 as parameter to install 4.x release

# default major version, comment to install puppet 3.x
PUPPETMAJORVERSION=4

### Code start ###
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
   if [ "$1" = 3 ]; then
     PUPPETMAJOR=3
     MODULEDIR="/etc/puppet/modules/"
   else
     PUPPETMAJOR=4
     MODULEDIR="/etc/puppetlabs/code/modules/"
  fi
else
  PUPPETMAJOR=$PUPPETMAJORVERSION
fi

# get or update repo
if [ -d /root/bussmtp ]; then
  echo "Update repo"
  cd /root/bussmtp
  git pull
else
  echo "Cloning repo"
  git clone https://github.com/pgomersbach/puppet-bussmtp.git /root/bussmtp
  cd /root/bussmtp
fi

# install puppet if not installed
if which puppet > /dev/null 2>&1; then
    bash /root/bussmtp/files/bootstrap.sh $PUPPETMAJOR
  else
    echo "Puppet is already installed."
fi

# prepare bundle
echo "Installing gems"
bundle install --path vendor/bundle
# install dependencies from .fixtures
echo "Preparing modules"
bundle exec rake spec_prep
# copy to puppet module location
cp -a /root/bussmtp/spec/fixtures/modules/* $MODULEDIR
echo "Run puppet apply"
puppet apply -e "include bussmtp"