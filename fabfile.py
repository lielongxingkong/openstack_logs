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
def update():
    with cd('/opt/windchimes'):
        run('git pull')
    run('swift-init storage restart')

@roles('meta')
def task2():
    run('ls ~/temp/ | wc -l')

def dotask():
    execute(task1)
    execute(task2)
