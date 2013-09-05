#!/bin/bash

CONFIG="./datanode.conf"

while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
case $name in
"ip")
ip=$value
;;
"swift_image_size")
swift_image_size=$value
;;
*)
;;
esac
done < $CONFIG

echo "Local IP has been set: ${ip}, used in swift"
echo "Swift_image is set: ${swift_image_size}MB"
echo "[zCloud]Confirm? (y/other exit)"
read confirm
if [ "$confirm" != "y" ]; then
exit 0
fi

service_running() {
    service $1 status >/dev/null
}


apt-get install -y xfsprogs 

if [ ! -d /swift ]; then
mkdir -p /swift
fi



#install swift datanode
apt-get install -y swift swift-account swift-container swift-object swift-doc 
cp ./datanode_configs/swift.conf /etc/swift/swift.conf
cp ./datanode_configs/account-server.conf /etc/swift/account-server.conf
cp ./datanode_configs/container-server.conf /etc/swift/container-server.conf
cp ./datanode_configs/object-server.conf /etc/swift/object-server.conf
chown -R swift:swift /swift

#install rsync
apt-get install -y rsync
cp ./datanode_configs/rsyncd.conf /etc/rsyncd.conf
sed -i "s/@ip_address@/${ip}/" /etc/rsyncd.conf
perl -pi -e 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync

if service_running rsync; then
	service rsync restart
else
	service rsync start
fi

#install rsyslog
cp ./datanode_configs/10-swift.conf /etc/rsyslog.d/10-swift.conf
mkdir -p /var/log/swift
chown -R syslog.adm /var/log/swift

if service_running rsyslog; then
	service rsyslog restart
else
	service rsyslog start
fi


