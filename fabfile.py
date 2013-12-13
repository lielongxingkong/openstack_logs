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
        run('python setup.py install')

@roles('data')
def data_restart():
    run('swift-init storage restart')

@roles('meta')
def meta_restart():
    run('swift-init all restart')

@roles('proxy')
def proxy_restart():
    run('swift-init proxy restart')

@roles('data', 'meta', 'proxy')
def cleanlog():
    run('service rsyslog stop')
    run('rm /var/log/swift/*')
    run('service rsyslog start')

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
