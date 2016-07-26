#!/bin/bash

# "2" is required for ipv6 as we are both a router and hosts
# see http://vk5tu.livejournal.com/37206.html
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
echo 1 > /proc/sys/net/ipv6/conf/default/forwarding
echo 1 > /proc/sys/net/ipv6/conf/all/accept_ra
echo 1 > /proc/sys/net/ipv6/conf/default/accept_ra

# Don't accept source routed packets
echo "0" > /proc/sys/net/ipv6/conf/all/accept_source_route

# Disable ICMP redirect acceptance
echo "0" > /proc/sys/net/ipv6/conf/all/accept_redirects


# Flush tables
ip6tables -F
#########################


# Set default Policy for the chains
ip6tables -P INPUT ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -P FORWARD ACCEPT
#########################

# reject function
ip6tables -X reject_func
ip6tables -N reject_func

ip6tables -A reject_func -p tcp -j REJECT --reject-with tcp-reset
ip6tables -A reject_func -p udp -j REJECT --reject-with icmp6-port-unreachable
ip6tables -A reject_func -j REJECT
#########################

# Set global to be allowed rules
ip6tables -A INPUT -m state --state INVALID -m limit --limit 5/m --limit-burst 10 -j LOG --log-prefix 'FW6-INVALID '
ip6tables -A INPUT -m state --state INVALID -j DROP
ip6tables -A OUTPUT -m state --state INVALID -j DROP
#ip6tables -A FORWARD -m state --state INVALID -j DROP
ip6tables -A INPUT -i lo -j ACCEPT


ip6tables -A INPUT -m state --state ESTABLISHED -j ACCEPT
ip6tables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT


ip6tables -A OUTPUT -o lo -j ACCEPT

ip6tables -A INPUT -p ICMPV6 -j ACCEPT

ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT



ip6tables -A OUTPUT -p ICMPV6 -j ACCEPT

ip6tables -A OUTPUT -j ACCEPT


ip6tables -A FORWARD -p ICMPV6 -j ACCEPT
ip6tables -A FORWARD -p tcp --dport 22 -j ACCEPT

ip6tables -A FORWARD -o tap0 -j ACCEPT
ip6tables -A FORWARD -i tap0 -o eth0.161 -j ACCEPT





# management rules - VLAN 141
ip6tables -A FORWARD -o eth0.141 -s 2001:610:120:e120:194:171:96:99 -d 2a02:6f00:1337:100::100/64 -j ACCEPT    # nlnode1.spacefed.net - radius
ip6tables -A FORWARD -o eth0.141 -s 2001:610:120:e120:194:171:96:98 -d 2a02:6f00:1337:100::100/64 -j ACCEPT    # kleurpotlood.nikhef.nl - radius



ip6tables -A FORWARD -o eth0.141 -d 2a02:6f00:1337:100:5054:ff:fee2:55db -p tcp --dport 80 -j ACCEPT  # iving
ip6tables -A FORWARD -o eth0.141 -d 2a02:6f00:1337:100:5054:ff:fee2:55db -p tcp --dport 443 -j ACCEPT  # iving
#######################################




ip6tables -A INPUT -m limit --limit 3/min -j LOG --log-prefix "FW6-IN " --log-tcp-options --log-ip-option
ip6tables -A FORWARD -m limit --limit 3/min -j LOG --log-prefix "FW6-FWD " --log-tcp-options --log-ip-option
