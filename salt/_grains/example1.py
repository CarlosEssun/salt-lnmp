#/usr/bin/python env
#coding:utf8
def Nginx_Grains():
    grains = {}
    grains['listen_port'] = '80'
    grains['root_path'] = '/data/www'
    grains['max_open_file'] = '65535'
    return grains
