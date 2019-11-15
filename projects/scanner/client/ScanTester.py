import sys
import struct

import numpy as np

import matplotlib
from importlib import reload
from PyQt5 import QtNetwork

import sys
sys.path.append(r'C:\Users\DJannis\Documents\Red Pitaya Scanner\red-pitaya-notes\projects\scanner\client')
import Scanner_Module as SM


ip = '143.129.150.93'

address = QtNetwork.QHostAddress()
address.setAddress('143.129.150.93')

#ip = '143.129.150.1'
scanner = SM.Scanner_module()
scanner.ConnectIPAdress(address)
scanner.socket.connected.connect(scanner.connected)
scanner.connected()
scanner.scan()

# An example script to connect to Google using socket
# programming in Python
import socket  # for socket
import sys

try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print("Socket successfully created")
except socket.error as err:
    print("socket creation failed with error %s" % (err))

# default port for socket
port = 80

try:
    host_ip = socket.gethostbyname('www.google.com')
except socket.gaierror:

    # this means could not resolve the host
    print
    "there was an error resolving the host"
    sys.exit()

# connecting to the server
s.connect((ip, 1001))

print
"the socket has successfully connected to google \
on port == %s" % (host_ip)

