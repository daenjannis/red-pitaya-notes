#!/usr/bin/env python

# Control program for the Red Pitaya Scanning system
# Copyright (C) 2015  Pavel Demin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import struct

import numpy as np
import time

import matplotlib
matplotlib.use('Qt5Agg')
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT as NavigationToolbar
from matplotlib.figure import Figure
import matplotlib.cm as cm
import matplotlib.pyplot as plt

from PyQt5.uic import loadUiType
from PyQt5.QtCore import QRegExp, QTimer, Qt
from PyQt5.QtGui import QRegExpValidator
from PyQt5 import QtGui
from PyQt5.QtWidgets import QApplication, QMainWindow, QMenu, QVBoxLayout, QSizePolicy, QMessageBox, QWidget, QFileDialog
from PyQt5.QtNetwork import QAbstractSocket, QTcpSocket

Ui_Scanner, QMainWindow = loadUiType('scanner.ui')

sys.path.append(r'C:\Users\DJannis\Documents\RedPitaya\red-pitaya-notes\projects\scanner\client')
import selfpatterncreator as spc

class Scanner(QMainWindow, Ui_Scanner):
  def __init__(self):
    super(Scanner, self).__init__()
    self.setupUi(self)
    # IP address validator
    rx = QRegExp('^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')
    self.addrValue.setValidator(QRegExpValidator(rx, self.addrValue))
    # state variable
    self.idle = True
    # number of samples to show on the plot
    self.xsize = self.xsizeValue.value()
    self.ysize = self.ysizeValue.value()
    self.size = self.xsize * self.ysize
    self.x = np.arange(self.xsize) #X array for plotting
    self.y = np.arange(self.ysize) #Y array for plotting
    self.freq = 125.0
    
    self.figure = Figure()
    self.figure.set_facecolor('none')
    self.axes = self.figure.add_subplot(111)
    self.canvas = FigureCanvas(self.figure)
    self.plotLayout.addWidget(self.canvas)
    self.change_scan_size()
    self.plotLayout.addWidget(self.toolbar)

    self.loadpatternButton.setEnabled(False)

    # create TCP socket
    self.socket = QTcpSocket(self)
    self.socket.connected.connect(self.connected)
    self.socket.readyRead.connect(self.read_data)
    self.socket.error.connect(self.display_error)
    # connect signals from buttons and boxes
    self.connectButton.clicked.connect(self.start)
    self.acquireButton.clicked.connect(self.acquire)
    self.searchButton.clicked.connect(self.search)
    self.searchButton.setCheckable(True)
    self.loadpatternButton.clicked.connect(self.file_open)
    self.saveButton.clicked.connect(self.save_file)
    self.periodValue.valueChanged.connect(self.set_period)
    self.trgtimeValue.valueChanged.connect(self.set_trgtime)
    self.trginvCheck.stateChanged.connect(self.set_trginv)
    self.shdelayValue.valueChanged.connect(self.set_shdelay)
    self.shtimeValue.valueChanged.connect(self.set_shtime)
    self.shinvCheck.stateChanged.connect(self.set_shinv)
    self.acqdelayValue.valueChanged.connect(self.set_acqdelay)
    self.samplesValue.valueChanged.connect(self.set_samples)
    self.pulsesValue.valueChanged.connect(self.set_pulses)
    self.xsizeValue.valueChanged.connect(self.set_xsize)
    self.ysizeValue.valueChanged.connect(self.set_ysize)
    self.checkBoxLoad.stateChanged.connect(self.state_changed)


    # create timers
    self.startTimer = QTimer(self)
    self.startTimer.timeout.connect(self.timeout)
    self.meshTimer = QTimer(self)
    self.meshTimer.timeout.connect(self.update_mesh)
    # set default values
    self.periodValue.setValue(200.0)

  def start(self):
    if self.idle:
      self.connectButton.setEnabled(False)
      self.socket.connectToHost(self.addrValue.text(), 1001)
      self.startTimer.start(5000)
    else:
      self.stop()

  def stop(self):
    self.idle = True
    self.socket.abort()
    self.offset = 0
    self.connectButton.setText('Connect')
    self.connectButton.setEnabled(True)
    self.acquireButton.setEnabled(True)

  def timeout(self):
    self.display_error('timeout')

  def connected(self):
    self.startTimer.stop()
    self.idle = False
    self.set_period(self.periodValue.value())
    self.set_trgtime(self.trgtimeValue.value())
    self.set_trginv(self.trginvCheck.checkState())
    self.set_shdelay(self.shdelayValue.value())
    self.set_shtime(self.shtimeValue.value())
    self.set_shinv(self.shinvCheck.checkState())
    self.set_acqdelay(self.acqdelayValue.value())
    self.set_samples(self.samplesValue.value())
    self.set_pulses(self.pulsesValue.value())
    # start pulse generators
    self.socket.write(struct.pack('<I', 11<<28))
    self.connectButton.setText('Disconnect')
    self.connectButton.setEnabled(True)
    self.acquireButton.setEnabled(True)

  def state_changed(self):
    if self.checkBoxLoad.isChecked():
      self.xsizeValue.setEnabled(False)
      self.ysizeValue.setEnabled(False)
      self.comboBoxScan.setEnabled(False)
      self.loadpatternButton.setEnabled(True)
    else:
      self.loadpatternButton.setEnabled(False)
      self.xsizeValue.setEnabled(True)
      self.ysizeValue.setEnabled(True)
      self.comboBoxScan.setEnabled(True)
      self.set_xsize(self.xsize)
      self.set_ysize(self.ysize)

  def set_loadedscanpattern(self, co):
    xco = co[0, :]
    yco = co[1, :]

    self.xsize = int(np.max(xco) + 1)
    self.ysize = int(np.max(yco) + 1)

    self.xsizeValue.setValue(self.xsize)
    self.ysizeValue.setValue(self.ysize)

    self.set_xsize(self.xsize)
    self.set_ysize(self.ysize)

    self.propx = 1
    self.propy = 1
    self.xco = xco
    self.yco = yco

  def file_open(self):
    fileName = QFileDialog.getOpenFileName(self, 'Open file', '', 'Text file (*.txt)')
    if not fileName[0]: return
    co = np.loadtxt(fileName[0], dtype = 'uint')
    self.set_loadedscanpattern(co)




  def read_data(self):
    size = self.socket.bytesAvailable()
    if self.offset + size < 8 * self.size:
      self.buffer[self.offset:self.offset + size] = self.socket.read(size)
      self.offset += size

    else:
      self.meshTimer.stop()
      self.buffer[self.offset:8 * self.size] = self.socket.read(8 * self.size - self.offset)
      self.offset = 0
      self.update_mesh()

      if self.searchButton.isChecked():
        self.socket.write(struct.pack('<I', 12<<28))
      else:
        self.changeButtonsState(True)

  def display_error(self, socketError):
    self.startTimer.stop()
    if socketError == 'timeout':
      QMessageBox.information(self, 'Scanner', 'Error: connection timeout.')
    else:
      QMessageBox.information(self, 'Scanner', 'Error: %s.' % self.socket.errorString())
    self.stop()

  def set_period(self, value):
    # set maximum delays and times to half period
    maximum = int(value * 5.0 + 0.5) / 10.0
    self.trgtimeValue.setMaximum(maximum)
    self.shdelayValue.setMaximum(maximum)
    self.shtimeValue.setMaximum(maximum)
    self.acqdelayValue.setMaximum(maximum)
    # set maximum number of samples per pulse
    maximum = int(value * 500.0 + 0.5) / 10.0
    if maximum > 256.0: maximum = 256.0
    self.samplesValue.setMaximum(maximum)
    shdelay = value * 0.25
    samples = value * 0.5
    if self.idle: return
    self.socket.write(struct.pack('<I', 0<<28 | int(value * self.freq)))

  def set_trgtime(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 1<<28 | int(value * self.freq)))

  def set_trginv(self, checked):
    if self.idle: return
    self.socket.write(struct.pack('<I', 2<<28 | int(checked == Qt.Checked)))

  def set_shdelay(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 3<<28 | int(value * self.freq)))

  def set_shtime(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 4<<28 | int(value * self.freq)))

  def set_shinv(self, checked):
    if self.idle: return
    self.socket.write(struct.pack('<I', 5<<28 | int(checked == Qt.Checked)))

  def set_acqdelay(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 6<<28 | int(value * self.freq)))

  def set_samples(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 7<<28 | int(value)))

  def set_pulses(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 8<<28 | int(value)))
    
  def set_xsize(self, value):
    self.xsize = value
    self.size = self.xsize * self.ysize
    self.x = np.arange(self.xsize)
    self.change_scan_size()
    
    
  def set_ysize(self, value):
    self.ysize = value
    self.size = self.xsize * self.ysize
    self.y = np.arange(self.ysize)
    self.change_scan_size()

  def change_scan_size(self):
    aspect = 1
    self.x = np.arange(self.xsize) #X array for plotting
    self.y = np.arange(self.ysize) #Y array for plotting
    
    # buffer and offset for the incoming samples
    self.buffer = bytearray(8 * self.xsize * self.ysize)
    self.offset = 0
    self.data = np.frombuffer(self.buffer, np.int32)
    # create figure
    self.axes.axis((0.0, self.ysize, 0.0, self.xsize))
    x, y = np.meshgrid(np.linspace(0.0, self.ysize, self.ysize+1), np.linspace(0.0, self.xsize, self.xsize+1))
    z = x / self.xsize + y * 0.0
    self.mesh = self.axes.pcolormesh(x, y, z, cmap = cm.gray,vmin = 0, vmax = 1)
    self.axes.set_aspect(aspect)
    # create navigation toolbar
    self.toolbar = NavigationToolbar(self.canvas, self.plotWidget, False)
    # remove subplots action
    actions = self.toolbar.actions()
    if int(matplotlib.__version__[0]) < 2:
      self.toolbar.removeAction(actions[7])
    else:
      self.toolbar.removeAction(actions[6])
    self.canvas.draw()


  def set_coordinates(self):
    if self.idle: return
    self.socket.write(struct.pack('<I', 9<<28))
    for i in range(self.xco.size):
        value = (self.xco_prop[i] + 0 << 18) | (self.yco_prop[i] << 4)
        self.socket.write(struct.pack('<I', 10<<28 | int(value)))

  def search(self):
    if self.idle: return
    if self.searchButton.isChecked() == True:
      self.acquire()


  def acquire(self):
    if self.idle: return
    self.changeButtonsState(False)
    if self.checkBoxLoad.isChecked()==False:
      self.set_scanpattern()

    self.data[:] = np.zeros(2 * self.xsize * self.ysize, np.int32)
    self.update_mesh()
    self.set_coordinates()
    self.socket.write(struct.pack('<I', 12<<28))
    self.meshTimer.start(self.plottimerValue.value())


  def set_scanpattern(self):
      scan_name = self.comboBoxScan.currentText()
      self.xco, self.yco = spc.LoadScanPattern(scan_name, self.xsize, self.ysize)
      self.propx = int(np.floor(1024 / (self.xsize)))
      self.propy = int(np.floor(1024 / (self.ysize)))

      self.xco_prop = self.propx * self.xco
      self.yco_prop = self.propy * self.yco

      self.orginaze_coordinates()

  def orginaze_coordinates(self):
    xco_prop = np.copy(self.xco_prop)
    yco_prop = np.copy(self.yco_prop)
    self.xco_prop[xco_prop<512] = self.xco_prop[xco_prop<512] + 512
    self.xco_prop[xco_prop >= 512] = self.xco_prop[xco_prop >= 512] - 512
    self.yco_prop[yco_prop<512] = self.yco_prop[yco_prop<512] + 512
    self.yco_prop[yco_prop >= 512] = self.yco_prop[yco_prop >= 512] - 512

  def update_mesh(self):
    result = self.data[0::2]/(self.samplesValue.value() * self.pulsesValue.value() * 8192.0)
    result = result - np.min(result)
    image = np.zeros((self.xsize, self.ysize))
    image[self.xco, self.yco] = result[:self.xco.size]
    vmini = np.min(result)
    vmaxi = np.max(result)
    self.mesh.set_array(image.reshape(self.xsize * self.ysize))
    self.mesh.set_clim(vmin = vmini, vmax = vmaxi)
    self.canvas.draw()

  def save_file(self):
    name = QFileDialog.getSaveFileName(self, 'Save File','','numPy array (*.npy)')
    if not name[0]:return
    else:
      try:
        scanlist = name[0][:-4]+'_scanlist.npy'
        savedat = np.zeros((3,self.xco.size))
        savedat[0, :] = self.xco
        savedat[1, :] = self.yco
        savedat[2, :] = self.data[0::2]/(self.samplesValue.value() * self.pulsesValue.value() * 8192.0)
        np.save(scanlist, savedat)

        image_name = name[0][:-4]+'_image.png'
        self.figure.savefig(image_name, bbox_inches='tight')

      except AttributeError:
        QMessageBox.information(self, 'Scanner', 'Error: no data acquired.')

  def changeButtonsState(self, boolean):
    self.acquireButton.setEnabled(boolean)
    self.loadpatternButton.setEnabled(boolean)
    self.saveButton.setEnabled(boolean)
    self.xsizeValue.setEnabled(boolean)
    self.ysizeValue.setEnabled(boolean)
    self.checkBoxLoad.setEnabled(boolean)
    self.comboBoxScan.setEnabled(boolean)


app = QApplication(sys.argv)
window = Scanner()
window.show()
sys.exit(app.exec_())
