{% set version = pillar['nginx']['version'] %}


add_user:
  user.present:
   - name: nginx
   - groups: 
      - nginx
   - createhome: False
   - shell: /sbin/nologin
  group.present:
   - name: nginx
     
/usr/local/src/nginx-{{version.replace('_','.')}}.tar.gz:
  file.managed:
    - source: salt://centos/public_service/nginx/1/{{version}}/nginx-{{version.replace('_','.')}}.tar.gz

tar -xf nginx-{{version.replace('_','.')}}.tar.gz -C /usr/local/:
  cmd.run:
    - cwd: /usr/local/src
    - unless: test -d /usr/local/nginx-{{version.replace('_','.')}}

/usr/local/nginx-{{version.replace('_','.')}}:
  file.directory:
   - require:
     - user: add_user

depend_nginx_pkg:
  pkg.installed:
    - pkgs:
       - pcre
       - pcre-devel
       - gcc
       - re2c
       - gcc-c++
       - ncurses-devel
       - elinks
       - openssl
       - openssl-devel
       - man

compiler_nginx_source_pkg:
  cmd.run:
    - cwd: /usr/local/nginx-{{pillar['nginx']['version'].replace('_','.')}}
    - name: ./configure --prefix=/opt/nginx  --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --user=nginx  --group=nginx --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=/var/tmp/nginx/client/ --http-proxy-temp-path=/var/tmp/nginx/proxy/ --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi --http-scgi-temp-path=/var/tmp/nginx/scgi --with-pcre &&make &&make install 1>/dev/null
    - unless: test -d /usr/local/src/nginx-{{pillar['nginx']['version'].replace('_','.')}}
    - require:
      - file: /usr/local/src/nginx-{{version.replace('_','.')}}.tar.gz
      - pkg: depend_nginx_pkg

