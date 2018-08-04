#!/bin/bash

source /opt/dhcp_influx/venv/bin/activate

cd /opt/dhcp_influx

python /opt/dhcp_influx/influx_dhcp_leases.py
