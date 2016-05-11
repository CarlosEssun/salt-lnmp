#!py
#coding:utf8
"""
生成my.cnf配置文件，如果文件存在，不做任何的修改
"""

import os 

def run():
  config={}
  version = __pillar__['mysql']['version']
  mysql_port = __pillar__['mysql']['port']
   #if not os.path.isfile('/data/mysql_data_%s/my.cnf'%(port)):
  config['/etc/my.cnf']={
       'file.managed':[{'source':'salt://centos/public_service/mysql/5/%s/my.cnf'%(version)},
                       {'template':'jinja'},
                       {'user':'mysql'},
                       {'group':'mysql'},    
                       {'context':{'port':mysql_port,'version':'%s'%(version.replace('_','.'))}},
                       {'require':[{'file':'/data/mysql_data_%s'%(mysql_port)}]},
                      ],}
   #config['chown mysql.mysql /data/mysql_data_%s/my.cnf'%(port)]='cmd.run'
  return config

