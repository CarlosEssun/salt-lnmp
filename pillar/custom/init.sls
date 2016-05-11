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
