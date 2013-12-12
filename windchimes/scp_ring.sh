#!/bin/bash
RING_CONF="./Ring.conf"

while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
ip=`echo $value|awk -F '|' '{print $2}' `
user=`echo $value|awk -F '|' '{print $5}' `
case $name in
"metanode")
	scp /etc/swift/account.ring.gz $user@$ip:/etc/swift/
	scp /etc/swift/container.ring.gz $user@$ip:/etc/swift/
	scp /etc/swift/object.ring.gz $user@$ip:/etc/swift/
;;
"datanode")
	scp /etc/swift/storage.ring.gz $user@$ip:/etc/swift/
;;
*)
;;
esac
done < $RING_CONF

