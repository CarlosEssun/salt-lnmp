{# Ink server faild to authenticate -- remove accepted key #}
{% if not data['result'] and data['id'].endswith('web') %}
minion_remove:
  wheel.key.delete:
    - match: {{ data['id'] }}
minion_rejoin:
  local.cmd.run:
    - tgt: salt-master.domain.tld
    - arg:
      - ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "{{ data['id'] }}" 'sleep 10 && /etc/init.d/salt-minion restart'
{% endif %}

{# Ink server is sending new key -- accept this key #}
{% if 'act' in data and data['act'] == 'pend' and data['id'].endswith('web') %}
minion_add:
  wheel.key.accept:
    - match: {{ data['id'] }}
{% endif %}


