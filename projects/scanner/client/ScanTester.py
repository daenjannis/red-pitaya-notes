import sys
import struct

import numpy as np

import matplotlib
from importlib import reload
from PyQt5 import QtNetwork

import sys
sys.path.append(r'C:\Users\DJannis\Documents\RedPitaya\red-pitaya-notes\projects\scanner\client')
import Scanner_Module as SM


ip = '143.129.150.93'

address = QtNetwork.QHostAddress()
address.setAddress('143.129.150.93')

#ip = '143.129.150.1'
scanner = SM.Scanner_module()
scanner.ConnectIPAdress(address)
# scanner.socket.connected.connect(scanner.connected)
# scanner.connected()
scanner.scan()


