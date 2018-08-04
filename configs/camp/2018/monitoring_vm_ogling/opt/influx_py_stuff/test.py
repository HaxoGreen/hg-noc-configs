#!/usr/bin/env python3

import influxdb
import json
import datetime

iflxc = influxdb.InfluxDBClient(host='94.242.211.3', port=8086)

iflxc.switch_database('entry_counter')


entry_point = [{'measurement': 'entry',
                'time': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'fields': {'count': 1}
               }
              ]

print(iflxc.write_points(entry_point, database='entry_counter'))

