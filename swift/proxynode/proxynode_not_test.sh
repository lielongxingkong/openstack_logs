#!/bin/bash

service_running () {
	service $1 status > /dev/null
}

RING_CONF="./zCloudRing.conf"

while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
case $name in
"proxy_ip")
	proxy_ip=`echo $value|awk -F '|' '{print $1}' `
;;
"keystone_ip")
	keystone_ip=`echo $value|awk -F '|' '{print $1}' `
;;
*)
;;
esac
done < $RING_CONF


cp ./proxy_configs/10-swift.conf /etc/rsyslog.d/
mkdir -p /var/log/swift/hourly
chown -R syslog.adm /var/log/swift
chmod -R g+w /var/log/swift
service rsyslog restart

apt-get update
apt-get -y install swift swift-proxy swift-doc memcached python-swiftclient python-webob

if ! service_running memcached ;then
	service memcached start
fi

if [ ! -d /etc/swift ]; then
	mkdir -p /etc/swift
	chown -R swift:swift /etc/swift/ 
fi

echo ${proxy_ip}
echo ${keystone_ip}
cp ./proxy_configs/proxy-server.conf /etc/swift/proxy-server.conf
cp ./proxy_configs/swift.conf /etc/swift/swift.conf
sed -i "s/%PROXY_IP%/${proxy_ip}/g" /etc/swift/proxy-server.conf
sed -i "s/%KEYSTONE_IP%/${keystone_ip}/g" /etc/swift/proxy-server.conf

sh ./ring.sh

if ! service_running swift-proxy ;then
	service swift-proxy start
else 
	service swift-proxy restart
fi
