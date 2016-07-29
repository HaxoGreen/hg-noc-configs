#!/usr/bin/env python

# sim0n

import subprocess
import json
import graphitesend
import time


data = {'ipv4': 0,
        'ipv6': 0,
        }

p = subprocess.Popen(['/usr/bin/pmacct', '-p/tmp/pmacct_ip.pipe', '-cdst_port', '-N*', '-S', '-r'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = p.communicate()

data['ipv4'] = int(out.strip())

p = subprocess.Popen(['/usr/bin/pmacct', '-p/tmp/pmacct_ip6.pipe', '-cdst_port', '-N*', '-S', '-r'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = p.communicate()

data['ipv6'] = int(out.strip())


#ports = [22, 23, 25, 80, 53, 123, 143, 110, 993, 443]
ports = [22, 80, 53, 123, 143, 443]
match_string = '-M"'

for p in ports:
  match_string += '*,{0};'.format(p)
  match_string += '{0},*;'.format(p)

match_string += '"'

p = subprocess.Popen(['/usr/bin/pmacct', '-p/tmp/pmacct_port.pipe', '-csrc_port,dst_port', match_string, '-Ojson', '-r'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = p.communicate()

for k in out.split('\n'):
  try:
    k_dict = json.loads(k)

    p = 0
    if not 'port_src' in k_dict or not 'port_dst' in k_dict:
      continue
    elif k_dict['port_dst'] in ports:
      p = k_dict['port_dst']
    elif k_dict['port_src'] in ports:
      p = k_dict['port_src']
    else:
      continue

    data['port_' + k_dict['ip_proto'] + '_' + str(p)] = k_dict['bytes']
  except Exception as e:
    print e
    continue

print data

# Graphite
graphite_server = "10.14.1.3"
graphite_prefix = ""
graphite_port = 2003

# Fetch interval (seconds). Set to False for single shot.
interval = False
graphite_dryrun = False
#graphite_dryrun = True


g = graphitesend.init(prefix=graphite_prefix,
                      dryrun=graphite_dryrun,
                      graphite_server=graphite_server,
                      graphite_port=graphite_port,
                      group="traffic_stats")

if interval is False:
    print g.send_dict(data)
else:
    while True:
        print g.send_dict(data)
        time.sleep(interval)
