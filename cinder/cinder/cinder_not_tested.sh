#!/bin/sh -e

service_running() {
    service $1 status >/dev/null
}

CONFIG="./config"
while read line; do
name=`echo $line|awk -F '=' '{print $1}'`
value=`echo $line|awk -F '=' '{print $2}'`
case $name in
"ip")
ip=$value
;;
"master")
master=$value
;;
*)
;;
esac
done < $CONFIG
sudo apt-get install -y mysql-server
sudo apt-get install -y python-mysqldb python-pip python-dev
pip install webob --upgrade 
pip install eventlet --upgrade
sudo apt-get install -y tgt=1:1.0.17-1ubuntu2
sudo apt-get --force-yes install -y  cinder-api cinder-scheduler cinder-volume iscsitarget \
    open-iscsi iscsitarget-dkms python-cinderclient linux-headers-`uname -r`

sed -i 's/false/true/g' /etc/default/iscsitarget
in_target=$(cat /etc/tgt/targets.conf|grep default-driver|wc -l)
if [ $in_target -le 0 ]; then
echo "default-driver iscsi" >> /etc/tgt/targets.conf
fi

if ! service_running iscsitarget ; then
service iscsitarget start
fi

if ! service_running open-iscsi ; then
service open-iscsi start
fi

sudo apt-get install -y xfsprogs
if [ ! -f /srv/cinder_image ]; then
sudo dd if=/dev/zero of=/srv/cinder_image bs=1M count=1000
fi

sudo mkfs.xfs -f /srv/cinder_image

sudo losetup /dev/loop1 /srv/cinder_image
sudo sed -i "/^exit 0$/i\/sbin/losetup /dev/loop1 /srv/cinder_image" /etc/rc.local

pvcreate /dev/loop1
vgcreate cinder-volumes /dev/loop1

cp ./cinder_configs/cinder.conf /etc/cinder/
cp ./cinder_configs/api-paste.ini /etc/cinder/

./openstack-db --service cinder --init
cinder-manage db sync

sed -i "s/%MASTER_IP%/${master}/g" /etc/cinder/cinder.conf
sed -i "s/%MASTER_IP%/${master}/g" /etc/cinder/api-paste.ini
sed -i "s/@IP_ADDRESS@/${ip}/g" /etc/cinder/cinder.conf
service cinder-api restart
service cinder-scheduler restart
service cinder-volume restart
