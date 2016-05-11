#!py
#coding:utf8
"""
生成php-fpm.conf配置文件，如果文件存在，不做任何的修改
"""

import os 

def run():
  config={}
  version = __pillar__['php']['version']
  php_port = __pillar__['php']['port'] 
  #if not os.path.isfile('/etc/nginx/nginx.conf'):
  config['/opt/php/etc/php-fpm.conf']={
       'file.managed':[{'source':'salt://centos/public_service/php/5/%s/php-fpm.conf'%(version)},
                       {'template':'jinja'},
                       {'user':'nginx'},
                       {'group':'nginx'},    
                       {'context':{'php_port':php_port,'user':'nginx'}},
                      ],}
  return config
