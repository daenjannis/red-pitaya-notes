import sys
import struct

import numpy as np

import matplotlib

matplotlib.use('Qt5Agg')
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT as NavigationToolbar
from matplotlib.figure import Figure
import matplotlib.cm as cm

from PyQt5.uic import loadUiType
from PyQt5.QtCore import QRegExp, QTimer, Qt
from PyQt5.QtGui import QRegExpValidator
from PyQt5.QtWidgets import QApplication, QMainWindow, QMenu, QVBoxLayout, QSizePolicy, QMessageBox, QWidget
from PyQt5.QtNetwork import QAbstractSocket, QTcpSocket
from PyQt5 import QtNetwork


class Scanner_module():
    def __init__(self):
        self.xsize = 512
        self.ysize = 512
        self.size = self.xsize * self.ysize
        self.freq = 125.0
        self.period = 200
        self.trgtime = 100
        self.trginv = 0
        self.shdelay = 1.5
        self.shtime = 0.1
        self.shinv = 0
        self.acqdelay = 10
        self.samples = 32
        self.pulses = 2
        self.idle = True
        self.socket = QTcpSocket()
        self.socket.connected.connect(self.connected)
        self.socket.readyRead.connect(self.read_data)
        # self.socket.error.connect(self.display_error)

        X, Y = np.meshgrid(np.arange(self.xsize),np.arange(self.ysize))
        self.xco = X
        self.yco = Y
        self.buffer = bytearray(8 * self.xsize*self.ysize)
        self.data = np.frombuffer(self.buffer, np.int32)

    def ConnectIPAdress(self, ip):
        if self.idle:
            self.socket.connectToHost(ip, 1001)
            if self.socket.waitForConnected(1000):
                print ("Connected!")

        else:
            self.stop()

    def stop(self):
        self.idle = True
        self.socket.abort()
        self.offset = 0

    def connected(self):
        self.idle = False
        self.send_period(self.period)
        self.send_trgtime(self.trgtime)
        self.send_trginv(self.trginv)
        self.send_shdelay(self.shdelay)
        self.send_shtime(self.shtime)
        self.send_shinv(self.shinv)
        self.send_acqdelay(self.acqdelay)
        self.send_samples(self.samples)
        self.send_pulses(self.pulses)
        # start pulse generators
        self.socket.write(struct.pack('<I', 11 << 28))

    def set_coordinates(self):
        x = self.xco.flatten()
        y = self.yco.flatten()

        if self.idle: return
        self.socket.write(struct.pack('<I', 9 << 28))
        for i in range(x.size):
                xco = x[i]
                yco = y[i]
                value = (xco << 18) | (yco << 4)
                self.socket.write(struct.pack('<I', 10 << 28 | int(value)))

    def scan(self):
        if self.idle: return
        self.data[:] = np.zeros(2 * 512 * 512, np.int32)
        self.set_coordinates()
        self.socket.write(struct.pack('<I', 12 << 28))
        print('scan send')

    def read_data(self):
        size = self.socket.bytesAvailable()
        if self.offset + size < 8 * self.size:
            self.buffer[self.offset:self.offset + size] = self.socket.read(size)
            self.offset += size
        else:
            self.buffer[self.offset:8 * self.size] = self.socket.read(8 * self.size - self.offset)
            self.offset = 0

    def send_period(self, value):
        # value = self.period
        if self.idle: return
        self.socket.write(struct.pack('<I', 0 << 28 | int(value * self.freq)))
        print('period send')

    def send_trgtime(self, value):
        # value = self.trgtime
        if self.idle: return
        self.socket.write(struct.pack('<I', 1 << 28 | int(value * self.freq)))

    def send_trginv(self, checked):
        # checked = self.trginv
        if self.idle: return
        self.socket.write(struct.pack('<I', 2 << 28 | int(checked)))

    def send_shdelay(self, value):
        # value = self.shdelay
        if self.idle: return
        self.socket.write(struct.pack('<I', 3 << 28 | int(value * self.freq)))

    def send_shtime(self, value):
        # value = self.shtime
        if self.idle: return
        self.socket.write(struct.pack('<I', 4 << 28 | int(value * self.freq)))

    def send_shinv(self, checked):
        # checked = self.shinv
        if self.idle: return
        self.socket.write(struct.pack('<I', 5 << 28 | int(checked)))

    def send_acqdelay(self, value):
        # value = self.acqdelay
        if self.idle: return
        self.socket.write(struct.pack('<I', 6 << 28 | int(value * self.freq)))

    def send_samples(self, value):
        # value = self.samples
        if self.idle: return
        self.socket.write(struct.pack('<I', 7 << 28 | int(value)))

    def send_pulses(self, value):
        # value = self.pulses
        if self.idle: return
        self.socket.write(struct.pack('<I', 8 << 28 | int(value)))