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
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT


# NAT
iptables -t nat -A POSTROUTING -s 10.16.1.0/32 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.16.0.0/32 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.16.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.17.0.0/24 -o eth0 -j MASQUERADE
