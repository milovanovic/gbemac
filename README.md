Gigabit Ethernet Media Access Controller
========================================================

## Overview
This repository contains a Chisel generator used to instantiate a run-time configurable Gigabit Ethernet Media Access Controller implemented in Verilog HDL. In order for the design to work properly, a set of appropriate values should be written into the memory mapped configurational registers and the external Ethernet transceiver should be configured. The list of relevant registers with their descriptions and address offsets is provided below.


|                        Content                        |                           Address offset                          |        Size[bits]        |
|:-----------------------------------------------------:|:-----------------------------------------------------------------:|:------------------------:|
|    PHY address of the ethernet transceiver device     |                                0x00                               |             5            |
|  Address of the register inside the tranceiver device |                                0x04                               |             5            |
|    Data to be written into the transceiver register   |                                0x08                               |            16            |
|         Write into the treanceiver register           |                                0x0C                               |             1            |
|   No preamble for the MDIO interface transactions     |                                0x10                               |             1            |
|      MDC clock divider (freq = 5MHz/divider)          |                                0x14                               |             8            |
|      Ethernet speed (should equal 4 for gigabit)      |                                0x18                               |             3            |
|            Full duplex bus (should equal 1)           |                                0x1C                               |             1            |
|                  Size of TCP packets                  |                                0x20                               |            16            |
|           Higher bytes of source MAC address          |                                0x9C                               |            24            |
|           Lower bytes of source MAC address           |                                0xA0                               |            24            |
|                  Source IP address                    |                                0xA4                               |            32            |
|                  Source port number                   |                                0xA8                               |            16            |
|        Higher bytes of destination MAC address        |                                0xAC                               |            24            |
|        Lower bytes of destination MAC address         |                                0xB0                               |            24            |
|                 Destination IP address                |                                0xB4                               |            32            |
|                 Destination port number               |                                0xB8                               |            16            |
|               Establish TCP connection                |                                0xBC                               |             1            |
|               Terminate TCP connection                |                                0xC0                               |             1            |
|                        Reset                          |                                0xC4                               |             1            |
