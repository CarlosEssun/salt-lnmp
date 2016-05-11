{# When an Ink server connects, run state.highstate. #}
add_cron_task:
  local.state.sls:
    - tgt: {{ data['id'] }}
    - arg: 
       - cxstom 
       
  
