#!/bin/bash
sed -i s/[[:space:]]//g ./Ring.conf
cp ./Ring.conf /etc/swift/

cd /etc/swift
RING_CONF="./Ring.conf"
swift-ring-builder account.builder create 18 3 1
swift-ring-builder container.builder create 18 3 1
swift-ring-builder object.builder create 18 3 1

while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
case $name in
"proxy_ip")
	proxy_ip=`echo $value|awk -F '|' '{print $1}'`
	proxy_user=`echo $value|awk -F '|' '{print $2}'`
;;
"datanode")
	zone=`echo $value|awk -F '|' '{print $1}'`
	ip=`echo $value|awk -F '|' '{print $2}'`
	swift_path=`echo $value|awk -F '|' '{print $3}'`
	weight=`echo $value|awk -F '|' '{print $4}'`
	swift-ring-builder account.builder add $zone-$ip:6002/$swift_path $weight
	swift-ring-builder container.builder add $zone-$ip:6001/$swift_path $weight
	swift-ring-builder object.builder add $zone-$ip:6000/$swift_path $weight
;;
*)
;;
esac
done < $RING_CONF

swift-ring-builder account.builder
swift-ring-builder container.builder 
swift-ring-builder object.builder 

swift-ring-builder account.builder rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder rebalance

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


rm /etc/swift/Ring.conf
