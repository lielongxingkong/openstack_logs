#!/bin/bash

cp ./hosts /etc/hosts
export LOCAL_NAME=datanode01
export LOCAL_IP=$LOCAL_NAME
echo $LOCAL_NAME > /etc/hostname
hostname $LOCAL_NAME

apt-get update 
PROJECT=windchimes
#ZIP=swift.zip
#ZIPNAME=swift
CODE=http://121.199.49.51/lielongxingkong/windchimes.git 
BRANCH=deploy

#unzip $ZIP 
#cp -r  ./$PROJECT /opt/$PROJECT

apt-get install -y curl gcc libffi-dev python-setuptools
apt-get install -y python-dev python-pip

apt-get install -y git git-core
git clone $CODE /opt/$PROJECT
cd /opt/$PROJECT
git fetch && git checkout $BRANCH
pip install -r /opt/$PROJECT/requirements.txt
#python setup.py install
cd -

mkdir -p /var/cache/swift /var/cache/swift1 /var/cache/swift2 /var/cache/swift3 /var/cache/swift4
find /var/cache/swift* -type f -name *.recon -exec rm -f {} \;
mkdir -p /etc/swift/

cat >/etc/swift/swift.conf <<EOF
[swift-hash]
swift_hash_path_suffix = randomestringchangeme
EOF

rm -f /var/log/debug /var/log/messages /var/log/rsyncd.log /var/log/syslog

apt-get install -y rsyslog
mkdir -p /var/log/swift
find /var/log/swift -type f -exec rm -f {} \;
chown -R syslog.adm /var/log/swift
cat >/etc/rsyslog.d/10-swift.conf<<EOF
local1,local2,local3,local4,local5.*   /var/log/swift/all.log

local1.*;local1.!notice        /var/log/swift/object.log
local1.notice                /var/log/swift/object.error
local1.*                ~
        
local2.*;local2.!notice        /var/log/swift/container.log
local2.notice                /var/log/swift/container.error
local2.*                ~

local3.*;local3.!notice        /var/log/swift/account.log
local3.notice                /var/log/swift/account.error
local3.*

local4.*;local4.!notice        /var/log/swift/storage.log
local4.notice                /var/log/swift/storage.error
local4.*

local5.*;local5.!notice        /var/log/swift/proxy.log
local5.notice                /var/log/swift/proxy.error
local5.*
EOF
service rsyslog restart
