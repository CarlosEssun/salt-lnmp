#!py
#coding:utf8
import commands

class Public_Server_Error(Exception):
   def __init__(self,value):
      self.value = value
   def __str__(self):
        return self.value

def check_opject_args(opj):
   service_sls_path='centos.public_service.'+opj
   require_args=['port','version']
 
   service=__pillar__.get(service_sls_path.split('.')[2],'')
   if service:
     for arg in require_args:
       if not service.has_key(arg) or str(service[arg]).strip()=="":
          raise Public_Server_Error('arg error key: %s'%arg)
 
       if not service['port'] or  not 70 < int(service['port']) < 65535:
          raise Public_Server_Error('service ports value error: %s' %(service['port']))
     cfg=service_sls_path+str(service['version'].split('_')[0])
     return cfg
   
def run():
   opject_list=['mysql.','nginx.','php.']

   config={}
   config['include']=[]
   for opj in opject_list:
      service_cfg=check_opject_args(opj)
      print service_cfg
      if service_cfg:
         config['include'].append(service_cfg)
   if config['include']==[]:
      return {}
   return config  
          
