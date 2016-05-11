# saltstack 整理笔记

## 自动化工具对比
### Ansible （YAML/SSH）

**优点**
* 基于SSH，不需要在远端部署节点上安装任何代理
* 使用YAML，学习曲线平滑
* 部署脚本使用Playbook，结构简单，清晰
* 分级变量定义控制作用范围，支持动态注册变量
* 比其他工具更精简的代码库
* 支持推送和PULL模式，可用于持续部署

**缺点**
* 相比于使用其他语言的工具，功能偏弱
* 使用自己的DSL，在熟悉前需要频繁查阅文档
* 变量传递，导致脚本复杂
* 输入、输出和配置不具有一致性

### Chef （Ruby）

**优点**
* 丰富的模块和配置集
* 代码驱动
* 以Git为中心的版本控制
**缺点**
* 学习曲线陡峭，需要熟悉ruby及过程编程
* 实际部署会导致大量的编程维护
* 不支持push模式

### Fabric （Python）

**优点**
* 可以部署任何语言的应用
* 相比其它工具，简单易用
* 与SSH深度集成

**缺点**
* 存在单点故障问题
* 采用推送模型，相比于Ansible，不太适合持续部署
* 仍需要Python语言环境


### Puppet （Ruby）

**优点**
* 可以通过Puppet Labs获得良好的社区支持
* 具有成熟的接口，支持绝大部分操作系统
* 简单的安装和初始化配置
* 完整的Web UI管理
* 强大的报表能力

**缺点**
* 对于比较高级的任务，需要使用CLI环境，必须熟悉Ruby
* 直接基于纯粹Ruby的配置在减少，多少基于自定义DSL
* 由于DSL不注重简洁，会导致大量臃肿的部署代码


### Saltstack （Python）

**优点**
* 完成安装后就可以直接组织和使用
* 其DSL有丰富的特性，不需要罗辑和状态
* 输入、输出和配置具有一致性（都是采用YAML）
* 通过Salt可以跟踪部署的执行情况
* 强大的社区支持

**缺点**
* 对新手来说难于安装和使用
* 对入门级层次来说，文档难于理解
* 对于非Linux系统支持差


## saltstack 介绍

`saltstack`
**官网:** https://saltstack.com/
**代码托管:** https://github.com/saltstack/salt
**描述:** 
salt是一个异构平台基础设置管理工具(虽然我们通常只用在Linux上)，使用轻量级的通讯器ZMQ,用Python写成的批量管理工具，完全开源，遵守Apache2协议，与Puppet，Chef功能类似，有一个强大的远程执行命令引擎，也有一个强大的配置管理系统，通常叫做Salt State System

**组件模型**
 > *  Salt-master 
 > *  Salt-minions
 > *  Execution Modules
 >> 对特定的一个或多个目录执行命令[状态监控，执行脚本，部署]
 > *  State 
 >>  系统配置操作集
 > *  Grains
>>  系统变量其中包含了操作系统类型，内存及其它属性，当然也可以自定义
 > *  Pillar
>>  用户自定义变量，存储于master上，分配到指定的目标上
 > * Top File
>> “头文件”用于匹配pillar数据及state文件
 > * Runners
>> 部署任务
 > * Returners
>> 将minion收集或执行的结果数据存储于master、DB或其它地方
 > * Reacor
>> 自动发现
 > * SSH
>>  通过ssh执行命令不需要minion
 > * Salt Cloud/Salt Virt
>> 基于云及虚拟化的管理

**工作模型**
`Agent and Server`
 管理服务器下发命令与配置，在各agent上执行，并将结果返回给server
`Agent-only`
如果你不想额外配置，它可以满足，它可以很“任性”加入到管理系统中
`Server-only`
salt 可以通过ssh来管理远程节点

**工作原理**

Salt stack的Master与Minion之间通过ZeroMq进行消息传递，使用了ZeroMq的发布-订阅模式，连接方式包括tcp，ipc
salt命令，将cmd.run ls命令从salt.client.LocalClient.cmd_cli发布到master，获取一个Jodid，根据jobid获取命令执行结果。
master接收到命令后，将要执行的命令发送给客户端minion。
minion从消息总线上接收到要处理的命令，交给minion._handle_aes处理
minion._handle_aes发起一个本地线程调用cmdmod执行ls命令。线程执行完ls后，调用minion._return_pub方法，将执行结果通过消息总线返回给master
master接收到客户端返回的结果，调用master._handle_aes方法，将结果写的文件中
salt.client.LocalClient.cmd_cli通过轮询获取Job执行结果，将结果输出到终端。

#####grains [属性]
salt有一个获取低层信息的接口--grains，它可以将收集像操作系统，域名，IP地址，内核及系统的其它信息，
grains是minion第一次启动的时候采集的静态数据，可以用在salt的模块和其他组件中。其实grains在每次的minion启动（重启）的时候都会采集，即向master汇报一次的。这个很重要，可以让某些同学企图使用grains值来做监控死心了。

* 定义属性

  通过minion的配置文件
开启包含文件--定义，之后需要重新启动`minion`就可以在 `master`获取了。

  通过grains 模块 
主要是通过grains.append与grains.setvals来添加，默认存储于`/etc/salt/grains`里面

  通过python 脚本
通过python脚本来实现，只需要定义字典或导入json模块，定义收集信息，返回字典

  grains  模块及说明
``` bash
[root@dev ~]# salt 'centos.dev.mail.web' sys.list_functions grains
centos.dev.mail.web:
    - grains.append
    - grains.delval
    - grains.filter_by
    - grains.get
    - grains.get_or_set_hash
    - grains.has_value
    - grains.item
    - grains.items
    - grains.ls
    - grains.remove
    - grains.setval
    - grains.setvals
```
单个函数的说明
```
[root@dev ~]# salt 'centos.dev.mail.web' sys.doc grains.ls
'grains.ls:'

    Return a list of all available grains

    CLI Example:

        salt '*' grains.ls
```
```
salt 'Minion' grains.get ipv4:2
```
*  grains  优先级
   最高级是：`master`端 $file_root/_grains 定义的属性会覆盖掉`minion`的所有同名的grains属性
   次之：`minion`端的/etc/salt/minion中包含定义的属性 
  最低：`minion`端的 `/etc/salt/grains`中定义的属性 [grains.append]
  最后就是 `salt` 中的core grains

* 定义grains
``` 
def open_moutil_port ():
    grains={}
    grains['web_port']='80'
    grains['mysql_path']='/data/mysql'
    grains['mysqld_port']='3307'
    grains['max_open_file']='65535'
    return grains
```
扩展的grains都存储于`/var/cahce/salt/minion/extmods/grains` 下面

* 同步 grains
```
salt '*' saltutil.sync_grains  #同步grains,自动刷新
salt '*' saltutil.sync_all  #同步有类型的组件
salt '*' state.highstate # 主动检索组件到指定的minion
```
* target  常用参数
 salt -E "mx[^2-4].*" test.ping


|  参数        |   匹配              |  例子                     |
|-----------:|:---------------:|:-------------------:|
|  L             |   列表形式匹配| -L 'centos.dev.mail.web','centos.dev.mail.mysql'
|  G             |  grains 匹配   | -G 'id:centos.dev.mail.mysql' 
|  E             |   正则匹配       | -E 'centos.dev.mail.[mysqlIweb]'
|   I             |   pillar匹配      | -I key:value
|  C             |   复合匹配       |  -C 'G@saltcol:verygood and L@centos.dev.mail.web'
|  S             |    子网              |  -S '192.168.1.0/24'
|   N           |    组别              | -N  groups


* 多环境并行
 [例子](https://docs.saltstack.com/en/latest/topics/tutorials/states_pt4.html)


#####pillar [变量]
  1. Pillar 是什么 ？
      `Pillar`是Salt非常重要的一个组件，它用于给特定的`minion`定义任何你需要的数据，这些数据可以被Salt的其他组件使用。Salt在0.9.8版本中引入了Pillar。Pillar在解析完成后，是一个嵌套的dict结构；最上层的key是minion ID，其value是该minion所拥有的Pillar数据；每一个value也都是key/value。
      而这些key与value都是我们自己根据实际需要定义的。而`grains`，我认为则是系统通用信息，当然`grains` 也可以在minion中定义，并上报到master，与grains 相比，`pillar`的灵活性更强。
      这里可以看出Pillar的一个特点，Pillar数据是与特定minion关联的，也就是说每一个minion都只能看到自己的数据，所以Pillar可以用来传递敏感数据（在Salt的设计中，Pillar使用独立的加密session，也是为了保证敏感数据的安全性）。
      
  2. Pillar可以用在那些地方
敏感数据
    例如`ssh key`，加密证书等，由于Pillar使用独立的加密session，可以确保这些敏感数据不被其他minion看到。
变量
    可以在Pillar中处理平台差异性，比如针对不同的操作系统设置软件包的名字，然后在State中引用。
其他任何数据
     可以在Pillar中添加任何需要用到的数据。比如定义用户和UID的对应关系，mnion的角色等。
用在`Target`中
    Pillar可以用来选择minion，使用-I选项。

  3. 怎么定义pillar数据
* master 的配置文件中定义
在默认的情况下，master配置文件中的所有数据都添加到pillar中，且对有所有的minion可用，如果要禁用这一默认值 ，可以在master的配置文件添加如下数据
```
pillar_opts: False 
```
* 使用SLS文件定义pillar
pillar使用与stats相似的SLS文件，pillar 所使用的根目录在master中通过pillar_roots来定义，因为默认使用YAML语法解析，所以要使用YAML的语法格式定义
```
pillar_roots:
  base:
 \   - /srv/pillar
```
这里定义了 base环境下的 pillar的目录，与state一样,pillar也需要top文件 ，也使用相同的匹配方式将数据应用到minion上，定义与state一样 : /srv/pillar/top.sls     
```
base:
  "*":
  \ - custom.install_web_ext
```
这样后就要在 /srv/pillar/创建一个custom的文件夹并在里面创建install_web_ext.sls[在salt中.(点)有特殊意义，我个人认为这是在分级]，如果custom中只有一个sls文件，也就可以将install_web_ext 改名在init，这样在top文件中也不用写custom.install_web_ext直接写custom 就可以了，因为默认是找init.sls文件。
* sls文件常定义的格式
使用jinja定义的，目录为 `/srv/pillar/coustom/install_web_ext.sls`
```
{% if grains['os'] == 'RedHat' %}
apache: httpd
git: git
{% elif grains['os'] == 'Debian' %}
apache: apache2
git: git-core
{% endif %}
```
利用条件判断与grains结合。
使用匹配方式,利用grains
```
dev:
  'os:Debian':
  \  - match: grain
   \ - servers
```
* 还有使用python自行定义
```
#!py
#coding:utf-8
import yaml
import os
def run():
  """
  根据ID特性补全项目路径，如果文件存在，利用yaml模块从文件中读取信息返回一个字典，如果文件不存返回是一个空
  ID ='cetos.dev.test.mail.mysql'
  """ 
  config={}
  id=__opts__['id']
  project=id.split('.')[-1]
  pillar_root=__opts__['pillar_roots']['base'][0]
  path='%s/custom/%s/%s.yaml' %(pillar_root,project,id)
  if os.path.isfile(path):
     s=open(path).read()
     config=yaml.load(s)
  return config
```
* pillar中数据是如何使用的
   pillar  解析后是dict对象，直接可以使用python语法，可以用索引（pillar['pkgs']['apace']）或get方法（pillar.get('user'),{}）.我更喜欢使用后者，如果匹配不到数据也不会报错
扩展的pillar

#####event 
查看事件：
```
salt-run state.event pretty=True
```
#####state vs Formulas state

* 前提
  `ymal`
  salt 的state 文件使用的是yaml标记语言，语法很简单，结构使用空格来控制，项目使用`-`,键值对使用`:`
  语法：
       缩进：两个空格
       冒号：键 值对
       短横杠： 列表
  `jinja`
     `jinja` 是基于python 的模板引擎，功能与php中的Smarty类似，而salt就是默认使用`jinja`来做渲染的，先用jinja2引擎处理SLS文件，之后再调用`YAML`解析器

    方法：
      在定义时使用 `- template: jinja`
      模板里的变量使用{{name}}
      在文件里要拽定变量列表
 [更多的应用](http://docs.jinkan.org/docs/jinja2/)

* state 
 state 文件是salt的核心，而这也就是他为什么会被叫做配置管理，sls文件默认格式是Yaml格式，并默认使用jinja模板，YAML是一种简单的适合用来传输数据 的格式，而jinja是根据Django的模板语言发展而来的语言，简单强大；state文件主要描述了系统，软件，服务，配置文件应该处于的状态。通常state，pillar,top file会用sls文件来编写。state文件默认是放在/srv/salt中，它与你的master配置文件中的file_roots设置有关。

1. 查看`state`列表
```
[root@salt ~]# salt 'centos.dev.mail.slave' sys.list_state_modules
centos.dev.mail.slave:
    - acl
    - alias
    - alternatives
    - archive
    - artifactory
    - at
    - blockdev
    - buildout
    - cloud
.......
```
2. 查看指定state的函数
```
[root@salt ~]# salt 'centos.dev.mail.slave' sys.list_state_functions user
centos.dev.mail.slave:
    - user.absent
    - user.present
```
3. 查看指定state的用法
```
[root@salt ~]# salt 'centos.dev.mail.slave' sys.state_doc user.absent
centos.dev.mail.slave:
    ----------
    user:
        
        Management of user accounts
        ===========================
        
        The user module is used to create and manage user settings, users can be set
        as either absent or present
        
            fred:
              user.present:
                - fullname: Fred Jones
                - shell: /bin/zsh
                - home: /home/fred
                - uid: 4000
                - gid: 4000
                - groups:
                  - wheel
                  - storage
                  - games
        
            testuser:
              user.absent
    user.absent:
        
            Ensure that the named user is absent
        
            name
                The name of the user to remove
        
            purge
                Set purge to True to delete all of the user's files as well as the user,
                Default is ``False``.
        
            force
                If the user is logged in, the absent state will fail. Set the force
                option to True to remove the user even if they are logged in. Not
                supported in FreeBSD and Solaris, Default is ``False``.
```
4. 写State的几种格式

high data
      高级数据我理解的就是我们编写sls文件的数据
low data
     低级数据就是经过render和parser编译过的数据 


 扩展的state 
* test.sls
```
/etc/sysconfig/network-scripts/ifcfg-:
  set_network_card.files:
    - interface: eth0_0
    - ipaddr: 192.168.1.99
    - netmask: 255.255.255.128
    - gateway: 192.168.0.254
  cmd.run:
    - name: service network restart
    - require:
        - set_network_card: /etc/sysconfig/network-scripts/ifcfg-
```

* _states/set_network_card.py
```
#! /usr/bin/env python
# coding:utf8
# date: 2016-4-7
# author: King.gp
# desc: set minion local network interface

from __future__ import absolute_import 
import salt.utils

def files(name='/etc/sysconfig/network-scripts/',
          interface=None,
          ipaddr=None,
          netmask=None,
          gateway=None):
    ret = {
	   'name':name,
           'changes':{},
           'result':True,
           'comment':''
	   }
    if interface and ipaddr and netmask and gateway:
       interface =':'.join(interface.split('_')) 
       name = ''.join([name,interface])
       file = __salt__['file.file_exists'](name)
       if __opts__['test']:
         ret['comment'] = 'some defaults has changed'
         ret['result'] = None
         return ret
       if not file:
         with open(name,'w') as cf:
           cf.write('DEVICE={0}\nTYPE=Ethernet\nONBOOT=yes\nBOOTPROTO=static\nIPADDR={1}\nNETMASK={2}\nGATEWAY={3}'.format(interface,ipaddr,netmask,gateway)) 
         ret['result'] = True
         ret['change'] = 'device name change to {0},\n ipaddr change to {1},\n netmask change to {2}.'
         ret['message'] = 'network card config file has changed'
       else: 
         ret['comment'] = '{0} not found'.format(name)
         ret['result'] = False
   
    else:
       ret['comment'] = 'interface {0} not set or ipaddr or netmask or gateway not None'.format(interface)  
       ret['result'] = False
    return ret

```
#####Return 
 *  执行过程
  `master`触发作业，然后由`minon`接收处理任务后直接与`return`存储服务器建立连接，然后将数据`return`存到存储服务器。
1. 修改源码



2. 自写reutns
在master上在添加mysql认证
```
[root@dev master.d]# cat mysql_auth.conf 
mysql.host: '127.0.0.1'
mysql.user: 'salt'
mysql.pass: 'salt'
mysql.db: 'salt'
mysql.port: 3306

```
创建数据库授权
```
CREATE DATABASE  `salt`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;
  
    USE `salt`;

--
-- Table structure for table `jids`
--

DROP TABLE IF EXISTS `jids`;
CREATE TABLE `jids` (
  `jid` varchar(255) NOT NULL,
  `load` mediumtext NOT NULL,
  UNIQUE KEY `jid` (`jid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `salt_returns`
--

DROP TABLE IF EXISTS `salt_returns`;
CREATE TABLE `salt_returns` (
  `fun` varchar(50) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `return` mediumtext NOT NULL,
  `id` varchar(255) NOT NULL,
  `success` varchar(10) NOT NULL,
  `full_ret` mediumtext NOT NULL,
  `alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `id` (`id`),
  KEY `jid` (`jid`),
  KEY `fun` (`fun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#授权
mysql> show grants for salt@'192.168.1.%';
+------------------------------------------------------------------------------------------------------------------------+
| Grants for salt@192.168.1.%                                                                                            |
+------------------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'salt'@'192.168.1.%' IDENTIFIED BY PASSWORD '*36F75ABC6D500DFA6E905046FD8BE5E115812DD0' |
+------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

```
定义returners
```
#!/bin/env python
#coding=utf8

# Import python libs
import json

# Import salt modules
import salt.config
import salt.utils.event

# Import third party libs
import MySQLdb

__opts__ = salt.config.client_config('/etc/salt/master')

# Create MySQL connect
conn = MySQLdb.connect(host=__opts__['mysql.host'], user=__opts__['mysql.user'], passwd=__opts__['mysql.pass'], db=__opts__['mysql.db'], port=__opts__['mysql.port'])
cursor = conn.cursor()

# Listen Salt Master Event System
event = salt.utils.event.MasterEvent(__opts__['sock_dir'])
for eachevent in event.iter_events(full=True):
    ret = eachevent['data']
    if "salt/job/" in eachevent['tag']:
        # Return Event
        if ret.has_key('id') and ret.has_key('return'):
            # Igonre saltutil.find_job event
            if ret['fun'] == "saltutil.find_job":
                continue

            sql = '''INSERT INTO `salt_returns`
                (`fun`, `jid`, `return`, `id`, `success`, `full_ret` )
                VALUES (%s, %s, %s, %s, %s, %s)'''
            cursor.execute(sql, (ret['fun'], ret['jid'],
                                 json.dumps(ret['return']), ret['id'],
                                 ret['success'], json.dumps(ret)))
            cursor.execute("COMMIT")
    # Other Event
    else:
        pass
```
测试
```
salt '*'    cmd.run 'ls'   --return=mysql
```


https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html

sls转化到json
```
In [14]: !cat test.sls
/tmp/foo.conf:
  file.managed:
   - source: salt://foo.conf
   - user: root
   - group: root
   - mode: 644
   - backup: minion

with open('test.sls','r')as f:
   print yaml.safe_load(f)

In [15]: with open('test.sls','r')as f:
    print json.dumps(yaml.safe_load(f),indent=4)
   ....:     
{
    "/tmp/foo.conf": {
        "file.managed": [
            {
                "source": "salt://foo.conf"
            }, 
            {
                "user": "root"
            }, 
            {
                "group": "root"
            }, 
            {
                "mode": 644
            }, 
            {
                "backup": "minion"
            }
        ]
    }
}

```
####自动化部署
> lnmp集群

```
[root@dev srv]# tree
.
├── pillar
│?? ├── custom
│?? │?? ├── init.sls
│?? │?? ├── init.slsc
│?? │?? ├── mysql
│?? │?? │?? └── centos.dev.mail.mysql.yaml
│?? │?? └── web
│?? │??     └── centos.dev.mail.web.yaml
│?? └── top.sls
├── reactor
│?? ├── auth-complete.sls
│?? └── auth-pending.sls
└── salt
    ├── centos
    │?? └── public_service
    │??     ├── init.sls
    │??     ├── mysql
    │??     │?? └── 5
    │??     │??     ├── 5_6_16
    │??     │??     │?? ├── my.cnf
    │??     │??     │?? ├── mysql-5.6.16.tar.gz
    │??     │??     │?? └── mysql.server
    │??     │??     ├── init.sls
    │??     │??     ├── instance.sls
    │??     │??     ├── my_cnf.sls
    │??     │??     └── packet.sls
    │??     ├── nginx
    │??     │?? └── 1
    │??     │??     ├── 1_8_0
    │??     │??     │?? ├── nginx
    │??     │??     │?? ├── nginx-1.8.0.tar.gz
    │??     │??     │?? └── nginx.conf
    │??     │??     ├── init.sls
    │??     │??     ├── instance.sls
    │??     │??     ├── nginx_conf.sls
    │??     │??     └── packet.sls
    │??     └── php
    │??         └── 5
    │??             ├── 5_5_30
    │??             │?? ├── conn.php
    │??             │?? ├── index.php
    │??             │?? ├── php-5.5.30.tar.gz
    │??             │?? ├── php-fpm
    │??             │?? └── php-fpm.conf
    │??             ├── init.sls
    │??             ├── instance.sls
    │??             ├── packet.sls
    │??             └── php_fpm.sls
    ├── cxstom
    │?? └── init.sls
    ├── _grains
    ├── _modules
    │?? ├── interface_flow.py
    │?? ├── tcp_connect_number.py
    │?? └── tcp_conn_status.py
    └── top.sls

20 directories, 36 files

```
`pillar`
```
[root@dev pillar]# cat top.sls 
base:
  '*':
   - custom

[root@dev pillar]# cat custom/
init.sls   init.slsc  mysql/     web/       
[root@dev pillar]# cat custom/init.sls
#!py
#coding:utf-8
import yaml
import os

def run():
  """
  根据ID特性补全项目路径，如果文件存在，利用yaml模块从文件中读取信息返回一个字典，如果文件不存返回是一个空
  ID ='cetos.dev.test.mail.mysql'
  """ 
  config={}
  id=__opts__['id']
  project=id.split('.')[-1]
  pillar_root=__opts__['pillar_roots']['base'][0]
  path='%s/custom/%s/%s.yaml' %(pillar_root,project,id)
  if os.path.isfile(path):
     s=open(path).read()
     config=yaml.load(s)
  return config

```


