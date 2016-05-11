'/usr/sbin/ntpdate time.windows.com':
  cron.present:
    - user: root
    - minute: 0
    - hour: '*/2'
    - comment: 'ntpdate sync'
