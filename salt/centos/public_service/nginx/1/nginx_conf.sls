#!py
#coding:utf8
"""
生成nginx.conf配置文件，如果文件存在，不做任何的修改
"""

import os 

def run():
  config={}
  version = __pillar__['nginx']['version']
  port = __pillar__['nginx']['port']
  php_port = __pillar__['php']['port'] 
  #if not os.path.isfile('/etc/nginx/nginx.conf'):
  config['/etc/nginx/nginx.conf']={
       'file.managed':[{'source':'salt://centos/public_service/nginx/1/%s/nginx.conf'%(version)},
                       {'template':'jinja'},
                       {'user':'nginx'},
                       {'group':'nginx'},    
                       {'context':{'port':port,'php_port':php_port}}
                      ],}
  return config
