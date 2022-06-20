#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 28 16:06:40 2022

@author: vukand
"""


import socket
import sys



TCP_IP = "192.168.33.30"
TCP_PORT = 4098
bufferSize  = 1026
try:
    TCPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_STREAM)

    TCPServerSocket.bind((TCP_IP, TCP_PORT))
    print('Device configured')
except:
    e = sys.exc_info()[0]
    print(e)

TCPServerSocket.listen()
print('After listen')
conn, addr = TCPServerSocket.accept()
print('After accept')

msgFromServer       = "Hello TCP Client"

bytesToSend         = str.encode(msgFromServer)

counter = 0

while(True):
    data1 = conn.recv(bufferSize)
    print(f"Received {data1[3]!r}")


TCPServerSocket.close()
print('Closing done')
