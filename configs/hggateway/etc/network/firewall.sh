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

# INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -d 224.0.0.1 -j DROP
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p ospf -j ACCEPT
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
iptables -A INPUT -i eth0.141 -p tcp -m tcp --dport 4949 -j ACCEPT
iptables -A INPUT -i eth0.141 -j ACCEPT


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
iptables -A FORWARD -d 192.168.1.0/24 -i eth0.666 -o eth3 -j DROP
iptables -A FORWARD -i eth0.666 -o tap+ -j ACCEPT
iptables -A FORWARD -d 31.22.122.1/32 -i tap+ -o eth0.666 -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A FORWARD -d 31.22.122.1/32 -i tap+ -o eth0.666 -j DROP
iptables -A FORWARD -d 31.22.122.0/23 -i tap+ -o eth0.666 -j ACCEPT
iptables -A FORWARD -i eth0.667 -o tap+ -j ACCEPT
iptables -A FORWARD -d 31.22.122.2/32 -i eth0.666 -j ACCEPT
iptables -A FORWARD -d 31.22.122.2/32 -i eth0.667 -j ACCEPT
iptables -A FORWARD -d 10.14.1.10/32 -i eth0.667 -j ACCEPT


iptables -t nat -A POSTROUTING ! -s 31.22.122.0/23 ! -d 192.168.1.0/24 -o tap+ -j MASQUERADE
iptables -t nat -A POSTROUTING -d 31.22.121.91/32 -o eth1 -j MASQUERADE


# wondershaper
wondershaper tap0 95000 95000
wondershaper tap1 25000 10000

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
