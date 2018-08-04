#!/usr/bin/env python3

import influxdb
import json
import datetime
import isc_dhcp_leases


iflxc = influxdb.InfluxDBClient(host='94.242.211.3', port=8086)
iflxc.switch_database('dhcpd')

leases = isc_dhcp_leases.IscDhcpLeases('/var/lib/dhcp/dhcpd.leases')

count = 0

for mac, lease in leases.get_current().items():
  if lease.ip.startswith('94.242'):
    count += 1


entry_point = [{'measurement': 'dhcp_leases',
                'time': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'fields': {'active': count}
               }
              ]

ret = iflxc.write_points(entry_point, database='dhcpd')

if not ret:
  ret = iflxc.write_points(entry_point, database='dhcpd')

print(count)
