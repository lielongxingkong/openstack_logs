#Openstack Swift集群部署说明

#####by ZhaoZhenlong

---

##1. 所有节点添加Openstack G版的apt源,参考 

+ apt-get install ubuntu-cloud-keyring

+ 添加  `deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main`
	- 到 **/etc/apt/sources.list.d/cloud-archive.list**

+ 添加 `deb http://archive.gplhost.com/debian grizzly main`
	- 到 **/etc/apt/sources.list.d/grizzly.list**
+ 添加 `deb http://archive.gplhost.com/debian grizzly-backports main`
	- 到 **/etc/apt/sources.list.d/grizzly.list**

+ apt-get update  

>注意  在运行 `apt-get update` 时有可能出现认证失败的提示,需要执行以下操作(其中十六进制码需要换成提示中出现的):

```
gpg --keyserver wwwkeys.pgp.net --recv-keys 64AA94D00B849883
gpg --armor --export 64AA94D00B849883 | apt-key add -
```

##2. 部署KEYSTONE节点

1. 安装Mysql,并修改 **/etc/mysql/my.cnf**,之后重启**mysql**服务 

```
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
```  

2. 向 **~/.bashrc** 中加入以下字段,然后执行 `source ~/.bashrc`  

```
export ADMIN_TOKEN=33092fa356a0837f703c
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0/
export SERVICE_TOKEN=$ADMIN_TOKEN
```

3. apt-get install keystone python-mysqldb

4. Run openstack-db to init keystone and swift database.
		openstack-db --service keystone --init

5. Modify /etc/keystone/keystone.conf by following:

```
[DEFAULT]
admin_token = 33092fa356a0837f703c
debug = True
verbose = True
```
	5)service keystone restart
	6)cd keystone and modify init_keystone.sh  
		KEYSTONE_HOST=192.168.100.20
	7)run init_keystone.sh

3.SWIFT/DATANODE
	1)Modify the config file datanode.conf
	2)Run datanode.sh  

3.SWIFT/PROXY_SERVER
	1)Modify the config file zCloudRing.conf . 
	2)Confirm EVERY NODE in zCloudRing.conf is reachable.
	3)Execute proxynode.sh (this script not tested)

