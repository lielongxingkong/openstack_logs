#!/bin/bash
apt-get install ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main" |sudo tee -a /etc/apt/sources.list.d/cloud-archive.list
echo "deb http://archive.gplhost.com/debian grizzly main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
echo "deb http://archive.gplhost.com/debian grizzly-backports main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
gpg --keyserver wwwkeys.pgp.net --recv-keys 64AA94D00B849883
gpg --armor --export 64AA94D00B849883 | apt-key add -
apt-get update

