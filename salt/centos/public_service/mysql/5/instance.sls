{% set port = pillar['mysql']['port'] %}

/data/mysql_data_{{port}}:
 file.directory:
   - makedirs: Ture
   - user: mysql
   - group: mysql
   - recurse: 
     - user
     - group


/etc/init.d/mysqld_{{port}}:
  file.managed:
    - source: salt://centos/public_service/mysql/5/{{pillar['mysql']['version']}}/mysql.server
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      port: {{port}} 
#      version: {{pillar['mysql']['version'].replace('_','.')}}


init_mysql_{{port}}:
  cmd.run:
    - cwd: /opt/mysql
    - name: scripts/mysql_install_db --user=mysql  --datadir=/data/mysql_data_{{port}}/ 1>/dev/null 
    - unless: ls -l /data/mysql_data_{{port}}  |grep -e ".* mysql$"


mysqld_{{port}}:
   service.running:
    - enable: Ture
    - watch:
       - cmd: init_mysql_{{port}}
       - file: /etc/init.d/mysqld_{{port}}

grant_user:
  cmd.run:
   - name: /opt/mysql/bin/mysql -e "grant all on *.* to 'david'@'192.168.1.114' identified by 'lovelove'"
   - watch:
     - service: mysqld_{{port}}
