# Import salt modules
import salt.client
import salt.config
def up():
    '''
    Print a list of all of the minions that are up
    '''
    __opts__ = salt.config.client_config('/etc/salt/master')
    client = salt.client.LocalClient(__opts__['conf_file'])
    minions = client.cmd('*', 'test.ping', timeout=10)
    if len(minions) > 0:
       ret = True
       for minion in sorted(minions):
         print minion
       return ret
