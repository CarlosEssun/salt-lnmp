import re
import time

def read_flow_file(func):
    
    """read network flow of '/proc/net/dev' """
    def get_flow(*args,**kwargs):
       with open('/proc/net/dev')as fn:
        data = fn.read()
        if not args:
            return {}
        patten = args[0] + '.*'
        kwargs['interface'] = args[0]
        if  not re.search(patten, data):

           kwargs['error'] = 'not match Net_interface'
           return kwargs
        Rev_old = re.search(patten, data).group().replace(':', ' ').split()[1]
        Send_old=re.search(patten, data).group().replace(':', ' ').split()[9]
        data_info= {}
        data_info['once_in'] = round((int(Rev_old)/1024/1024), 0)
        data_info['once_out'] = round((int(Send_old)/1024/1024), 0)
        time.sleep(1)
        fn.seek(0)
        data=fn.read()
        Rev=re.search(patten,data).group().replace(':',' ').split()[1]
        Send=re.search(patten,data).group().replace(':',' ').split()[9]
        data_info['current_in'] = round((int(Rev)/1024/1024), 0)
        data_info['current_out']= round((int(Send)/1024/1024), 0)
        temp_list = []
        for k,v in data_info.items():
            temp_list.append(k+':'+str(v)+'M')
        kwargs['net_info'] =temp_list
        return kwargs
     
    return get_flow  

@read_flow_file
def run(args):
  return args
print run('eth0')
