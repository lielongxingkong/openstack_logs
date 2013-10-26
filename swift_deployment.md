#Openstack Swift集群部署说明

#####by ZhaoZhenlong

---
##0. 集群中节点的职能:
+ 192.168.9.1 
	+ **ntp-server**
	+ **puppet-master**
	+ **zabbix-server**
+ 192.168.9.11 
	+ **swift proxy-server**
+ 192.168.9.2-22 
	+ **swift data-server**


+ 对应写到**/etc/hosts**,分发到每个节点

> **/etc/hosts**示例:    

```
192.168.9.1     ntp
192.168.9.1     puppet
192.168.9.1     zabbix-server
192.168.9.11    proxy01
192.168.9.2     datanode01
192.168.9.3     datanode02
192.168.9.4     datanode03
192.168.9.12    datanode04
192.168.9.13    datanode05
192.168.9.14    datanode06
192.168.9.15    datanode07
192.168.9.22    datanode08
```


+ 集群中所有节点配置**ssh信任**: **所有**节点生成密钥,将公钥拷贝到**同一个**节点(如192.168.9.1),并由该节点将authorized_keys分发到每个节点的 **.ssh** 目录中:

```
everynode:~/.ssh# cd .ssh/
everynode:~/.ssh# ssh-keygen -t rsa
(Enter Enter Enter)
everynode:~/.ssh# ssh-copy-id -i id_rsa.pub root@192.168.9.1
192.168.9.1:~/.ssh# scp ~/.ssh/authorized_keys root@everynode:~/.ssh/
```




##1. 所有节点添加Openstack G版的apt源  

> 参考脚本 **prepare_grizzly.sh**

+ **apt-get install ubuntu-cloud-keyring**

+ 添加  `deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main`
	- 到 **/etc/apt/sources.list.d/cloud-archive.list**

+ 添加 `deb http://archive.gplhost.com/debian grizzly main`
	- 到 **/etc/apt/sources.list.d/grizzly.list**

+ 添加 `deb http://archive.gplhost.com/debian grizzly-backports main`
	- 到 **/etc/apt/sources.list.d/grizzly.list**

+ apt-get update  

> 注意  在运行 `apt-get update` 时有可能出现认证失败的提示,需要执行以下操作(其中十六进制码需要换成提示中出现的):

```
gpg --keyserver wwwkeys.pgp.net --recv-keys 64AA94D00B849883
gpg --armor --export 64AA94D00B849883 | apt-key add -
```

##2. 部署KEYSTONE节点

+ 安装Mysql,并修改 **/etc/mysql/my.cnf**,之后重启**mysql**服务  

```
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
```  

+ 向 **~/.bashrc** 中加入以下字段,然后执行 `source ~/.bashrc`  

```
export ADMIN_TOKEN=33092fa356a0837f703c
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0/
export SERVICE_TOKEN=$ADMIN_TOKEN
```

+ 安装keystone包以及相关的python库  

```
apt-get install keystone python-mysqldb
```

+ 初始化keystone数据库,相关脚本 **openstack-db**  

```
openstack-db --service keystone --init
```

> **openstack-db**用来初始化Openstack各组件的数据库表,修改自Redhat的版本,keystone服务运行正常,其它组件尚未测试

+ 修改keystone配置文件 **/etc/keystone/keystone.conf**

```
[DEFAULT]
admin_token = 33092fa356a0837f703c
debug = True
verbose = True
```

> 注意:此处的**admin_token** 应当与前述 **ADMIN_TOKEN** 值一致  

+ 重启keystone服务   

```
service keystone restart
```

+ 修改 **keystone** 目录下的 **init_keystone.sh**,修改成实际中的参数,例如:   

```
KEYSTONE_HOST=192.168.9.11
```

+ 运行 **init_keystone.sh**

> ###**keystone节点部署完成**

##3. 利用Puppet部署swift组件
###puppet的安装和部署
+ 安装ruby相关软件包   

```
apt-get install ruby libshadow-ruby1.8
```  

+ **master**安装puppet相关软件包   

```
apt-get install puppet puppetmaster facter
``` 
+ **agent**安装puppet相关软件包   

```
apt-get install puppet facter
```

**puppet master**的配置 **/etc/puppet/puppet.conf**: 

```
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post

[master]
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
certname = puppet
reports = log, foreman

[agent]
report = true
```

**puppet-agent**的配置 **/etc/puppet/puppet.conf**:

```
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post
server=puppet
pluginsync = true

[master]
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
```
配置完成后,puppet-master启动服务:

```
service puppetmaster start
```

###利用puppet进行swift的部署   
> **/etc/puppet** 有两个重要的目录: 
>   
> > **manifests**中存放puppet的配置(**site.pp**根据实际情况完成节点部署,很重要 **!**)    
> > **modules**中存放puppet部署组件的配置库(其中的swift目录中包含了自己修改的配置,与官方提供的配置相比有修改,很重要 **!**)

对于每个节点,与puppet-master通信获得配置,之后将进行自动部署

```
puppet agent -t --certname datanode02 --debug
```

> 每一个agent与master通信的过程中,需要完成一次认证才能开始部署,在**master**上执行:

```
puppet cert --list
puppet cert --sign buctsim03  (--all可认证所有待认证节点)
```
> 利用puppet尚未完成Swift Ring的自动生成,需要调用脚本 **openstack_logs/swift/for_puppet/ring.sh** 来生成Ring和进行分发,其中配置文件 **zCloudRing.conf** 用来配置节点信息

> > zClondRing.conf示例和说明:   

```
proxy_ip=192.168.9.11|root
keystone_ip=192.168.9.11
datanode=z1|192.168.9.2|c0d1|72|root
datanode=z2|192.168.9.3|c0d1|72|root
datanode=z3|192.168.9.4|c0d1|72|root
datanode=z4|192.168.9.12|c0d1|72|root
datanode=z5|192.168.9.13|c0d1|72|root
datanode=z6|192.168.9.14|c0d1|72|root
datanode=z7|192.168.9.15|c0d1|72|root
```

> > proxy_ip=IP|用户名   
> > datanode=Zone|IP|卷名称|Weight|用户名 

在每个启动swift相关服务:

```
swift-init all stop
swift-init all start
```
> ###**swift集群部署完成**

##4. swift的使用

可新建一个快速访问脚本**quickswift**放在 **/usr/local/bin** 中:

```
#!/bin/sh
swift -V 2.0 -A http://192.168.9.11:5000/v2.0 -U services:swift -K admin $*
```

具体用法可执行`quickswift -h`进行查看