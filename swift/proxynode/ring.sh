#!/bin/bash
sudo cp ./zCloudRing.conf /etc/swift/

cd /etc/swift
RING_CONF="./zCloudRing.conf"
sudo swift-ring-builder account.builder create 18 3 1
sudo swift-ring-builder container.builder create 18 3 1
sudo swift-ring-builder object.builder create 18 3 1

while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
case $name in
"proxy_ip")
	proxy_ip=`echo $value|awk -F '|' '{print $1}' `
	proxy_user=`echo $value|awk -F '|' '{print $2}' `
;;
"datanode")
	zone=`echo $value|awk -F '|' '{print $1}' `
	ip=`echo $value|awk -F '|' '{print $2}' `
	path= `echo $value|awk -F '|' '{print $3}' `
	weight=`echo $value|awk -F '|' '{print $4}' `
	sudo swift-ring-builder account.builder add $zone-$ip:6002/$path $weight
	sudo swift-ring-builder container.builder add $zone-$ip:6001/$path $weight
	sudo swift-ring-builder object.builder add $zone-$ip:6000/$path $weight
;;
*)
;;
esac
done < $RING_CONF

sudo swift-ring-builder account.builder
sudo swift-ring-builder container.builder 
sudo swift-ring-builder object.builder 

sudo swift-ring-builder account.builder rebalance
sudo swift-ring-builder container.builder rebalance
sudo swift-ring-builder object.builder rebalance

while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
case $name in
"datanode")
	ip=`echo $value|awk -F '|' '{print $2}' `
	user=`echo $value|awk -F '|' '{print $5}' `
	scp /etc/swift/*.gz $user@$ip:/etc/swift/
;;
*)
;;
esac
done < $RING_CONF


sudo rm /etc/swift/zCloudRing.conf
