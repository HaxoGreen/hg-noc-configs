#!/usr/bin/python

import json
import fileinput
import socket
import time

CARBON_SERVER = '1.2.3.4'
CARBON_PORT = 2003
sock = socket.socket()
sock.connect((CARBON_SERVER, CARBON_PORT))



for line in fileinput.input():
    data = json.loads(line)
    print data
    temp = False
    if 'temperature_F' in data.keys():
        temp = round((data['temperature_F'] - 32) / 1.8)
    if 'temperature_C' in data.keys():
        temp = data['temperature_C']

    chan = data['channel']
    _id = data['id']

    if 'humidity' in data.keys():
        humd = data['humidity']
        humd = "433.%s.%s.humidity %s %d" % (chan,_id,data['humidity'],int(time.time()))
        print humd
        sock.sendall("%s\n"%humd)

    if temp != False:
        temp = "433.%s.%s.temperature %s %d" % (chan,_id,temp,int(time.time()))
        print temp
        sock.sendall("%s\n"%temp)
sock.close()
