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


sudo apt-get install -y xfsprogs 
#Local config image file 10G path: /srv/swift_image
if [ ! -f /srv/swift_image ]; then
#sudo dd if=/dev/zero of=/srv/swift_image bs=1M count=${swift_image_size}
truncate -s ${swift_image_size}MB /srv/swift_image
fi

sudo mkfs.xfs -f /srv/swift_image
infstab=$(cat /etc/fstab|grep swift_image|wc -l)
if [ $infstab -le 0 ]; then
echo "/srv/swift_image /swift xfs loop=/dev/loop0,noatime,nodiratime,nobarrier,logbufs=8 0 0" |sudo tee -a /etc/fstab
fi 

if [ ! -d /swift ]; then
sudo mkdir -p /swift
fi

if ! sudo mount /swift; then
echo "[zCloud]Mount Failed, has /swift been mounted? press c to continue other to exit"
read conti
	if [ $conti != 'c' ]; then
	exit 0
	fi
fi


#install swift datanode
sudo apt-get install -y swift swift-account swift-container swift-object swift-doc 
sudo cp ./datanode_configs/swift.conf /etc/swift/swift.conf
sudo cp ./datanode_configs/account-server.conf /etc/swift/account-server.conf
sudo cp ./datanode_configs/container-server.conf /etc/swift/container-server.conf
sudo cp ./datanode_configs/object-server.conf /etc/swift/object-server.conf
sudo chown -R swift:swift /swift

#install rsync
sudo apt-get install -y rsync
sudo cp ./datanode_configs/rsyncd.conf /etc/rsyncd.conf
sudo sed -i "s/@ip_address@/${ip}/" /etc/rsyncd.conf
sudo perl -pi -e 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync

if service_running rsync; then
	sudo service rsync restart
else
	sudo service rsync start
fi

#install rsyslog
sudo cp ./datanode_configs/10-swift.conf /etc/rsyslog.d/10-swift.conf
sudo mkdir -p /var/log/swift
sudo chown -R syslog.adm /var/log/swift

if service_running rsyslog; then
	sudo service rsyslog restart
else
	sudo service rsyslog start
fi

if [ -f /tmp/account.ring.gz ] && [ -f /tmp/container.ring.gz ] && [ -f /tmp/object.ring.gz ] ; then
	sudo cp /tmp/account.ring.gz /tmp/object.ring.gz /tmp/container.ring.gz /etc/swift/
	sudo swift-init all restart
else
	echo "Proxy server rebuild ring and distribute, then run: swift-init all start"
fi

