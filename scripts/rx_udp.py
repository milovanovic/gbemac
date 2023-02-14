#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 11 16:41:31 2022

@author: vukand
"""

import socket
import sys



UDP_IP = "192.168.33.30"
UDP_PORT = 4098
bufferSize  = 1024
try:
    UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

    UDPServerSocket.bind((UDP_IP, UDP_PORT))
    print('Device configured')
except:
    e = sys.exc_info()[0]
    print(e)



msgFromServer       = "Hello UDP Client"

bytesToSend         = str.encode(msgFromServer)

counter = 0

while(True):
    
    print('Before receive')
    bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
    print('After receive')

    message = bytesAddressPair[0]
    #message = 205
    
    address = bytesAddressPair[1]
    #address = ('192.168.30.33', 1024)
    #address = ('192.168.255.255', 1024)
    
    clientMsg = "Message from Client:{}".format(message[6])
    clientIP  = "Client IP Address:{}".format(address)
    
    #if (counter < 2):
    print(clientMsg)
    print(clientIP)
    
    # Sending a reply to client
    #UDPServerSocket.sendto(bytesToSend, address)
    #counter = counter + 1
        
        
UDPServerSocket.sock.close()
