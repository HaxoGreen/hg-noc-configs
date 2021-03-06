#!/bin/bash

echo 0 > /proc/sys/net/ipv4/tcp_timestamps
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/secure_redirects
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo 1 > /proc/sys/net/ipv4/ip_forward

# Cleanup
iptables -F
iptables -F -t nat
iptables -F -t mangle

# Set default policy
iptables -P INPUT DROP
#iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# DROP
iptables -A INPUT -i eth0.161 -d 10.16.0.0/24 -j DROP
iptables -A INPUT -i eth0.161 -d 10.17.0.0/24 -j DROP

# INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT -i eth2 -p ospf -j ACCEPT
iptables -A INPUT -i tap0 -p ospf -j ACCEPT
iptables -A INPUT -i tap1 -p ospf -j ACCEPT

iptables -A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 4 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 67 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 68 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 123 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 123 -j ACCEPT
iptables -A INPUT -i eth0.141 -j ACCEPT
#iptables -A INPUT -i eth0.171 -j ACCEPT #test

#iptables -A INPUT -j LOG
iptables -A INPUT -d 224.0.0.1 -j DROP


#OUTPUT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT


# FORWARD
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -p icmp -m icmp --icmp-type 3 -j ACCEPT
iptables -A FORWARD -p icmp -m icmp --icmp-type 4 -j ACCEPT
iptables -A FORWARD -p icmp -m icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -p icmp -m icmp --icmp-type 11 -j ACCEPT
iptables -A FORWARD -i eth0.141 -j ACCEPT
iptables -A FORWARD -i eth0.171 -j ACCEPT 
iptables -A FORWARD -i eth0.161 -o tap+ -j ACCEPT
iptables -A FORWARD -d 31.22.122.1/32 -i tap+ -o eth0.161 -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A FORWARD -d 31.22.122.1/32 -i tap+ -o eth0.161 -j DROP
iptables -A FORWARD -d 31.22.122.0/23 -i tap+ -o eth0.161 -j ACCEPT
iptables -A FORWARD -i eth0.161 -o tap+ -j ACCEPT
iptables -A FORWARD -d 31.22.122.2/32 -i eth0.161 -j ACCEPT
iptables -A FORWARD -d 31.22.122.2/32 -i eth0.171 -j ACCEPT
iptables -A FORWARD -d 10.14.1.10/32 -i eth0.171 -j ACCEPT
iptables -A FORWARD -d 192.168.1.0/24 -i eth0.141 -j ACCEPT
iptables -A FORWARD -d 192.168.178.9/24 -i eth0.141 -j ACCEPT

iptables -A FORWARD -d 10.14.1.3 -p tcp --dport 80 -j ACCEPT  # iving
iptables -A FORWARD -d 10.14.1.3 -p tcp --dport 443 -j ACCEPT  # iving
iptables -A FORWARD -d 10.14.1.3 -p icmp -j ACCEPT  # iving
iptables -A FORWARD -i tap+ -s 10.16.0.1 -d 10.14.1.3 -p tcp --dport 2003 -j ACCEPT  # iving - grafana
iptables -A FORWARD -i tap+ -s 10.17.0.1 -d 10.14.1.3 -p tcp --dport 2003 -j ACCEPT  # iving - grafana



# NAT
iptables -t nat -A PREROUTING -d 31.22.122.222 -j DNAT --to-destination 10.14.1.3
iptables -t nat -A POSTROUTING -o eth0.141 -d 10.14.1.3 -j SNAT --to-source 10.14.1.1



iptables -t nat -A POSTROUTING ! -s 31.22.122.0/23 ! -d 192.168.1.0/24 -o tap+ -j MASQUERADE
iptables -t nat -A POSTROUTING -d 31.22.121.90/32 -o eth1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.14.1.0/24 -d 192.168.1.0/24 -o eth2 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.14.1.0/24 -d 192.168.178.0/24 -o eth1 -j MASQUERADE


# wondershaper
#wondershaper tap0 95000 95000
#wondershaper tap1 25000 10000
#
iptables -t mangle -A PREROUTING -p icmp -j TOS --set-tos Minimize-Delay

iptables -t mangle -A PREROUTING -p ospf -j TOS --set-tos Minimize-Delay

iptables -t mangle -A PREROUTING -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp --dport ssh -j TOS --set-tos Minimize-Delay

iptables -t mangle -A PREROUTING -p tcp --dport 53 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p udp --dport 53 -j TOS --set-tos Minimize-Delay

iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp --dport 443 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp --dport 25 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp --dport 143 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp --dport 6667 -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp --dport 5222 -j TOS --set-tos Minimize-Delay
