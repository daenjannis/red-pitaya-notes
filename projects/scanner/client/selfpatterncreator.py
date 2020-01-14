import numpy as np
import matplotlib.pyplot as plt




def RandomPattern(xsize, ysize):
    X, Y = np.meshgrid(np.arange(ysize), np.arange(xsize))
    yco =X.flatten().astype('int')
    np.random.shuffle(yco)
    xco =Y.flatten().astype('int')
    np.random.shuffle(xco)
    return xco, yco

def NormalPattern(xsize, ysize):
    X, Y = np.meshgrid(np.arange(ysize), np.arange(xsize))
    yco =X.flatten().astype('int')
    xco =Y.flatten().astype('int')
    return xco, yco

def SnakeScan(xsize, ysize):
    X, Y = np.meshgrid(np.arange(ysize), np.arange(xsize))
    X[1::2, :] = X[1::2, ::-1]
    yco =X.flatten().astype('int')
    xco =Y.flatten().astype('int')
    return xco, yco


def HilberPattern(xsize, ysize):
    order = int(np.max(np.ceil([np.log2(xsize), np.log2(ysize)])))
    
    A = np.zeros((0,2));
    B = np.zeros_like(A)
    C = np.zeros_like(A)
    D = np.zeros_like(A)
    
    north = np.array([[ 0,  1]])
    east  = np.array([[ 1,  0]])
    south = np.array([[ 0, -1]])
    west  = np.array([[-1,  0]])

    for i in range(int(order)):
            AA = np.concatenate((B, north, A, east, A, south, C))
            BB = np.concatenate((A, east, B, north, B, west, D))
            CC = np.concatenate((D, west, C, south, C, east, A))
            DD = np.concatenate((C, south, D, west, D, north, B))
            A = AA
            B = BB
            C = CC
            D = DD
    
    
    co = np.concatenate((np.array([[0, 0]]),np.cumsum(A, axis = 0))).astype('int')
    return co[:,0], co[:,1]

def LoadScanPattern(scan_name, xsize, ysize):
    if scan_name ==  'Normal Scan':
        xco, yco = NormalPattern(xsize, ysize)
    elif scan_name ==  'Random Scan':
        xco, yco = RandomPattern(xsize, ysize)
    elif scan_name ==  'Snake Scan':
        xco, yco = SnakeScan(xsize, ysize)
    elif scan_name ==  'Hilbert Scan':
        boolean1 = np.ceil([np.log2(xsize)]) == np.floor([np.log2(xsize)]) #a power of 2
        boolean2 = xsize == ysize #x and y size has to be the same.
        if boolean1 * boolean2:
            xco, yco = HilberPattern(xsize, ysize)
        else:
            print('Use the same x and y dimension and it needs to be a power of two')
            xco, yco = NormalPattern(xsize, ysize)
    return xco, yco




