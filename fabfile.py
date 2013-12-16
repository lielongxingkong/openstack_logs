#!/usr/bin/env python
# encoding: utf-8

from fabric.api import *

env.roledefs = {
	'data' : [
		'datanode01', 
		'datanode02',
		'datanode03',
		'datanode04',
		'datanode05',
	],  
	'meta' : ['meta', ],
	'proxy': ['proxy',], 
}

env.password = "root"

DATA_DISK = 'vdc'
META_DISKS = ['vdc', 'vdd', 'vde', 'vdf']

@roles('data')
def data_mount():
    run('mount -t xfs /dev/vdc /srv/node/vdc')
    run('mount')
    run('ls /srv/node/vdc')

@roles('meta')
def meta_mount():
    for disk in META_DISKS:
	run('mount -t xfs /dev/%s /srv/node/%s' % (disk, disk))
	run('ls /srv/node/%s' % disk)
    run('mount')

@roles('data', 'meta', 'proxy')
def cleanlog():
    run('service rsyslog stop')
    run('rm /var/log/swift/*')
    run('service rsyslog start')

@roles('data')
def resetdata():
    with cd('/root/windchimes'):
    	run('bash ./mkdatanode')
@roles('meta')
def resetmeta():
    with cd('/root/windchimes'):
    	run('bash ./mkmetanode')
@roles('proxy')
def resetproxy():
    with cd('/root/windchimes'):
    	run('bash ./mkproxy')

@roles('data','meta','proxy')
def update():
    with cd('/opt/windchimes'):
        run('git checkout develop')
        run('git pull')
        run('python setup.py develop')

@roles('data')
def data_restart():
    run('swift-init storage restart')

@roles('meta')
def meta_restart():
    run('swift-init account restart')
    run('swift-init container restart')
    run('swift-init object restart')

@roles('proxy')
def proxy_restart():
    run('swift-init proxy restart')

@roles('data')
def data_start():
    run('swift-init storage start')

@roles('meta')
def meta_start():
    run('swift-init account start')
    run('swift-init container start')
    run('swift-init object start')

@roles('proxy')
def proxy_start():
    run('swift-init proxy start')

@roles('proxy')
def proxy_stop():
    run('swift-init proxy stop')

@roles('data')
def data_stop():
    run('swift-init storage stop')

@roles('meta')
def meta_stop():
    run('swift-init account stop')
    run('swift-init container stop')
    run('swift-init object stop')

def dotask():
    execute(cleanlog)
    execute(update)

def reset():
    execute(resetdata)
    execute(resetmeta)
    execute(resetproxy)

def restart():
    execute(data_restart)
    execute(meta_restart)
    execute(proxy_restart)

def start():
    execute(data_start)
    execute(meta_start)
    execute(proxy_start)

def stop():
    execute(data_stop)
    execute(meta_stop)
    execute(proxy_stop)
