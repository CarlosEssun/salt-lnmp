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
