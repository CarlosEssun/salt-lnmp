/opt/nginx:
 file.directory:
   - makedirs: Ture
   - user: nginx 
   - group: nginx
   - recurse:
     - user
     - group


/etc/init.d/nginx:
  file.managed:
    - source: salt://centos/public_service/nginx/1/{{pillar['nginx']['version']}}/nginx
    - user: root
    - group: root
    - mode: 755

start_nginx_service:
  service.running:
   - name: nginx
   - enable: True
   - watch:
      - file: /etc/init.d/nginx
