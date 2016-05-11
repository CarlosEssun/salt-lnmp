/etc/sysconfig/network-scripts/ifcfg-:
  set_network_card.files:
    - interface: eth0_0
    - ipaddr: 192.168.1.99
    - netmask: 255.255.255.128
    - gateway: 192.168.0.254
  cmd.run:
    - name: service network restart
    - require:
        - set_network_card: /etc/sysconfig/network-scripts/ifcfg-
