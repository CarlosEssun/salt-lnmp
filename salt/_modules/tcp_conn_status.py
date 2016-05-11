#!/usr/bin/env python
# coding:utf8
# date: 2016-01-07
# author: King.gp
# version: 0.1
# desc:
"""
check local tcp connect status
"""

from __future__ import absolute_import

# Import salt libs
import salt.utils

# Import python libs
import logging
import re
import os

log = logging.getLogger(__name__)
__virtualname__ = 'tcp_conn_status'


def __virtual__():
    '''
     test file exists
    '''
    return True if os.path.isfile('/proc/net/tcp') else False

def tcp_status(path='/proc/net/tcp'):
  '''
  salt * tcp_conn_status.tcp_status
  '''
  with open(path) as ft:
     lines = ft.readlines()
     status_code = {'00':'ERROR_STATUS','01':'TCP_ESTABLISHED','02':'TCP_SYN_SENT','03':'TCP_SYN_RECV',
                '04':'TCP_FIN_WAIT1','05':'TCP_FIN_WAIT2','06':'TCP_TIME_WAIT','07':'TCP_CLOSE','08':'TCP_CLOSE_WAIT','09':'TCP_LAST_ACK','0A':'TCP_LISTEN','0B':'TCP_CLOSING'}
     status_result = {}
     result= ''
     sum  = 0 
     for line in lines:
        line = line.replace('\n','')
        if (line[34:36]) in status_code.keys():
           sum +=1
           status_result[status_code[line[34:36]]] =sum
     for key,value in status_result.iteritems():
       result+=key+'\t'+str(value)+'\n'   
     return result,  
