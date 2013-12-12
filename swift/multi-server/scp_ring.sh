#!/bin/bash
RING_CONF="./Ring.conf"

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

