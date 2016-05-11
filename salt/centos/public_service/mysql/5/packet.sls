{% set version = pillar['mysql']['version'] %}

mysql:
  user.present:
    - createhome: False
    - shell: /sbin/nologin


/usr/local/src/mysql-{{version.replace('_','.')}}.tar.gz:
  file.managed:
    - source: salt://centos/public_service/mysql/5/{{version}}/mysql-{{version.replace('_','.')}}.tar.gz

tar -xf mysql-{{version.replace('_','.')}}.tar.gz -C /usr/local/:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d /usr/local/mysql-{{version.replace('_','.')}}

/usr/local/mysql-{{version.replace('_','.')}}:
  file.directory:
   - user: mysql
   - group: mysql
   - recurse:
     - user
     - group
   - require: 
     - user: mysql

/data/mysqld_log:
   file.directory:
    - makedirs: Ture
    - user: mysql 
    - group: mysql
    - recurse:
       - user
       - group


/data/log-bin:
  file.directory:
    - makedirs: True
    - user: mysql
    - group: mysql
    - recurse:
      - user
      - group


depend_pkg:
  pkg.installed:
    - pkgs:
       - libaio
       - cmake
       - ncurses-devel
       - openssl-devel
       - man

compiler_source_pkg:
  cmd.run:
    - cwd: /usr/local/mysql-{{pillar['mysql']['version'].replace('_','.')}}
    - name: cmake . -DCMAKE_INSTALL_PREFIX=/opt/mysql  -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DENABLE_DOWNLOADS=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_LIBWRAP=0 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci && make && make install 1>/dev/null
    - unless: test -d /usr/local/src/mysql-{{pillar['mysql']['version'].replace('_','.')}}
    - require:
      - file: /usr/local/src/mysql-{{version.replace('_','.')}}.tar.gz

set_mysql_envionment_variables:
   cmd.run:
    - name: echo "export PATH=/opt/mysql/bin:$PATH" >/etc/profile.d/mysql.sh && source /etc/profile.d/mysql.sh
    - unless: env | grep /opt/mysql/bin
    - require: 
      - cmd: compiler_source_pkg

create_include_directory:
  file.directory:
    - makedirs: True
    - name: /usr/include/mysql
    - require: 
      - cmd: compiler_source_pkg

import_man_file:
  cmd.run:
   - name: echo "MANPATH /opt/mysql/man" >>/etc/man.config
   - unless: grep "mysql\b" /etc/man.config


