#!/bin/bash
#apt-get install mysql-server
apt-get update
apt-get install ubuntu-cloud-keyring
gpg --keyserver wwwkeys.pgp.net --recv-keys 16126D3A3E5C1192 
gpg --armor --export 16126D3A3E5C1192 | apt-key add -
gpg --keyserver wwwkeys.pgp.net --recv-keys 64AA94D00B849883 
gpg --armor --export 64AA94D00B849883 | apt-key add -
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main" >> /etc/apt/sources.list.d/cloud-archive.list
echo "deb http://archive.gplhost.com/debian grizzly main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
echo "deb http://archive.gplhost.com/debian grizzly-backports main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
apt-get update
ntpdate ntp
#sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
#service mysql restart
#apt-get install -y rabbitmq-server
#rabbitmqctl change_password guest rabbit

