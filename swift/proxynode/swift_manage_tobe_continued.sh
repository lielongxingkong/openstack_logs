#!/bin/bash

usage() {
cat << EOF
[zzl]help
command:
	create 
	add [{ip}]
	rebalance
	distribute [all|{ip}]
	restart-datanode [all|{ip}]
	auto-rebuild
	destroy
EOF
  exit $1
}

check_ip() {
if [ `echo $1 | awk -F . '{print NF}'` -ne 4 ];then
        usage 1
else
        a=`echo $1 | awk -F . '{print $1}'`
        b=`echo $1 | awk -F . '{print $2}'`
        c=`echo $1 | awk -F . '{print $3}'`
        d=`echo $1 | awk -F . '{print $4}'`
        if [[ $a -gt 0 && $a -le 255 ]] && [[ $b -ge 0 && $b -le 255 ]] && [[ $c -ge 0 && $c -le 255 ]] && [[ $d -gt 0 && $d -lt 255 ]];then
                echo "confirm ip y/other exit"
                read confirm
                if [ ! $confirm = 'y' ]; then
                        exit 1
                fi
        else
                usage 1
        fi
fi
}



while [ $# -gt 0 ]; do
  case "$1" in
    help) usage 0 ;;
    create) MODE='create' 
	if [$# -ne 1] ;then
		echo "create should not contain parameters"
		usage 1
	fi
    ;;
    add) MODE='add'
   	if [$# -ne 2] ;then
		echo "add should contain an ip address"
		usage 1
	else
		if [! check_ip $2 ]; then
			echo "Invalid IP"
			usage 1
		fi
	fi
    ;;
	
    rebalance) MODE='rebalance' ;;
    distribute) MODE='distribute' ;;
    restart-datanode) MODE='restart-datanode' ;;
    auto-rebuild) MODE='auto-rebuild' ;;
    destroy) MODE='destroy' ;;
    *)
	echo 'Unrecognized command'  
	usage 1 
	;; # ignore
  esac
done






CONFIG="./ring.conf"

while read line; do
	if [ $line = #* ] ;then
	continue
	fi

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

cd /etc/swift
sudo swift-ring-builder account.builder create 18 3 1
sudo swift-ring-builder container.builder create 18 3 1
sudo swift-ring-builder object.builder create 18 3 1


