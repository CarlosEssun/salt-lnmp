{% set version = pillar['php']['version'] %}
include:
  - centos.public_service.nginx.1
/opt/php:
 file.directory:
   - makedirs: Ture
   - user: nginx
   - group: nginx
   - recurse:
     - user
     - group

/usr/lib/mysql:
  file.directory:
    - makedirs: Ture
    
/usr/local/src/php-{{version.replace('_','.')}}.tar.gz:
  file.managed:
    - source: salt://centos/public_service/php/5/{{version}}/php-{{version.replace('_','.')}}.tar.gz

tar -xf php-{{version.replace('_','.')}}.tar.gz -C /usr/local/:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d /usr/local/php-{{version.replace('_','.')}}

/usr/local/php-{{version.replace('_','.')}}:
  file.directory

depend_pkg:
  pkg.installed:
    - pkgs:
       - libxml2-devel 
       - libpng-devel 
       - freetype-devel 
       - openssl-devel 
       - libcurl-devel
       - libmcrypt 
       - bison
       - bison-devel
       - bison-runtime
       - libjpeg-turbo
       - libjpeg-turbo-devel
       - libmcrypt-devel
       - mysql
       - mysql-devel
create_link_libmcrypt:
  cmd.run:
    - name: cp /usr/lib64/mysql/* /usr/lib/mysql/
    - require:
       - pkg: depend_pkg
       - file: /usr/lib/mysql

compiler_source_pkg:
  cmd.run:
    - cwd: /usr/local/php-{{pillar['php']['version'].replace('_','.')}}
    - name: ./configure --prefix=/opt/php --with-config-file-path=/opt/php/etc --with-mysql=/usr  --with-mysqli=/usr/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath  --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex  --enable-fpm  --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-pdo-mysql --with-mysql-sock=/var/mysql/mysql.sock  &&make &&make install 1>/dev/null
    - unless: test -d /usr/local/src/php-{{pillar['php']['version'].replace('_','.')}}
    - require:
      - file: /usr/local/src/php-{{version.replace('_','.')}}.tar.gz
      - cmd: create_link_libmcrypt

