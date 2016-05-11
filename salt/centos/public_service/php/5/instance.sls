/etc/init.d/php-fpm:
  file.managed:
    - source: salt://centos/public_service/php/5/{{pillar['php']['version']}}/php-fpm
    - user: root
    - group: root
    - mode: 755

rename_php_execute:
  cmd.run:
   - name: mv /usr/bin/php /usr/bin/php53
   - unless: test -f /usr/bin/php53

mod_php_version:
  cmd.run:
   - name: ln -s /opt/php/bin/php /usr/bin/
   - unless: test -L /usr/bin/php
   - watch:
     - cmd: rename_php_execute

/opt/nginx/html/index.php:
  file.managed:
   - source: salt://centos/public_service/php/5/{{pillar['php']['version']}}/index.php
   - user: nginx
   - group: nginx
   - require:
     - service: php-fpm

php-fpm:
  service.running:
   - enable: True
   - watch:
      - file: /etc/init.d/php-fpm

/opt/nginx/html/t.php:
  file.managed:
   - source: salt://centos/public_service/php/5/{{pillar['php']['version']}}/conn.php
   - user: nginx
   - group: nginx
   - require:
     - service: php-fpm
