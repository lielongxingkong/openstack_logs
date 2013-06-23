#!/bin/bash
apt-get install -y ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main" >> /etc/apt/sources.list.d/cloud-archive.list
apt-get update
echo "deb http://archive.gplhost.com/debian grizzly main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
echo "deb http://archive.gplhost.com/debian grizzly-backports main" |sudo tee -a /etc/apt/sources.list.d/grizzly.list
apt-get update
apt-get install -y rabbitmq-server
#set rabbitmq user guest password rabbit
rabbitmqctl change_password guest rabbit

