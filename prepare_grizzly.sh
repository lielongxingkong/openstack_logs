#!/bin/bash
apt-get install mysql-server
apt-get install ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main" >> /etc/apt/sources.list.d/cloud-archive.list
apt-get update
echo "deb http://archive.gplhost.com/debian grizzly main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
echo "deb http://archive.gplhost.com/debian grizzly-backports main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
gpg --keyserver wwwkeys.pgp.net --recv-keys 64AA94D00B849883
gpg --armor --export 64AA94D00B849883 | apt-key add -
apt-get update
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
service mysql restart
#apt-get install -y rabbitmq-server
#rabbitmqctl change_password guest rabbit

