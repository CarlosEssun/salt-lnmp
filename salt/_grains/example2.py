#!/usr/bin/env python
# coding: utf8

def grains():
  local_test={}
  test={'a':1,'b':2,'c':3}
  local_test['list']=['A','B','C','D'] 
  local_test['str']='show go on'
  local_test['dict']=test
  return local_test


