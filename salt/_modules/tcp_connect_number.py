#!/usr/bin/env python
# coding: utf8

import os
import re

def run():
  ret = {}
  type_list=['Tcp','Udp']
  check_file = '/proc/net/snmp'
  if os.path.exists(check_file):
    with open(check_file) as f1:
      data=f1.read()
      for t in type_list:
        patten =re.compile('%s:\s+\d.*'%t,re.I)
        m = patten.search(data)
        if not m:
            ret['type_error'] = "%s type ont found" %t
            return ret
        if t=='Tcp':
          # tcp_new_connect_number:通过/proc/net/snmp文件得到最近240秒内PassiveOpens的增量，除以240得到每秒的平均增量 
          # tcp_current_estab: 通过/proc/net/snmp文件的CurrEstab得到TCP连接数
  
          tcp_new_connect_number_per = (int(m.group().replace(':', ' ').split()[6]))/240
          tcp_current_estab = m.group().replace(':', ' ').split()[8]
          ret['current_tcp_estab'] = tcp_current_estab
          ret['new_tcp_per'] = tcp_new_connect_number_per
        # udp_outdatagrams_per: 通过/proc/net/snmp文件得到最近240秒内InDatagrams的增量，除以240得到平均每秒的UDP接收数据报。
        # udp_indatagrams_per: 通过/proc/net/snmp文件得到最近240秒内OutDatagrams的增量，除以240得到平均每秒的UDP发送数据报。
        udp_outdatagrams_per = (int(m.group().replace(':', ' ').split()[4]))/240
        udp_indatagrams_per = (int(m.group().replace(':', ' ').split()[1]))/240
        ret['udp_outdatagrams_per'] = udp_outdatagrams_per
        ret['udp_indatagrams_per'] = udp_indatagrams_per
      return ret
    
  ret['error']='%s not found' %check_file
  return ret
print run()
