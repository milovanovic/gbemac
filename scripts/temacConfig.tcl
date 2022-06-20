reset_hw_axi [get_hw_axis hw_axi_1]

set baseAddrGbemac 0x20000000

# phy address
create_hw_axi_txn write_txn1 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x00]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn1]
# no preamble
create_hw_axi_txn write_txn2 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x10]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn2]
# clock divider, clk = 5MHz/divider
create_hw_axi_txn write_txn3 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x14]] -len 1 -data {0000000A}
run_hw_axi [get_hw_axi_txns write_txn3]
# speed
create_hw_axi_txn write_txn4 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x18]] -len 1 -data {00000004}
run_hw_axi [get_hw_axi_txns write_txn4]
# full duplex
create_hw_axi_txn write_txn5 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x1C]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn5]
# packet size
create_hw_axi_txn write_txn6 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x20]] -len 1 -data {00000400}
run_hw_axi [get_hw_axi_txns write_txn6]
# source MAC Address higher bytes
create_hw_axi_txn write_txn7 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x9C]] -len 1 -data {000004A3}
run_hw_axi [get_hw_axi_txns write_txn7]
# source MAC Address lower bytes
create_hw_axi_txn write_txn8 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xA0]] -len 1 -data {00123456}
run_hw_axi [get_hw_axi_txns write_txn8]
# source IP address
create_hw_axi_txn write_txn9 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xA4]] -len 1 -data {C0A81E21}
run_hw_axi [get_hw_axi_txns write_txn9]
# source port
create_hw_axi_txn write_txn10 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xA8]] -len 1 -data {000027D7}
run_hw_axi [get_hw_axi_txns write_txn10]
# destination MAC address higher bytes
create_hw_axi_txn write_txn11 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xAC]] -len 1 -data {0040B076}
run_hw_axi [get_hw_axi_txns write_txn11]
# destination MAC address lower bytes
create_hw_axi_txn write_txn12 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xB0]] -len 1 -data {00A47912}
run_hw_axi [get_hw_axi_txns write_txn12]
# destination IP address
create_hw_axi_txn write_txn13 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xB4]] -len 1 -data {C0A8211E}
run_hw_axi [get_hw_axi_txns write_txn13]
# destination port
create_hw_axi_txn write_txn14 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xB8]] -len 1 -data {00001002}
run_hw_axi [get_hw_axi_txns write_txn14]

### 1G SPEED
# reg address
create_hw_axi_txn write_txn15 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x04]] -len 1 -data {00000009}
run_hw_axi [get_hw_axi_txns write_txn15]
# data
create_hw_axi_txn write_txn16 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x08]] -len 1 -data {00000200}
run_hw_axi [get_hw_axi_txns write_txn16]
# write enable
create_hw_axi_txn write_txn17 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x0C]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn17]

after 500

### Not 10_100 SPEED
# write disable
create_hw_axi_txn write_txn18 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x0C]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn18]
# reg address
create_hw_axi_txn write_txn19 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x04]] -len 1 -data {00000004}
run_hw_axi [get_hw_axi_txns write_txn19]
# data
create_hw_axi_txn write_txn20 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x08]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn20]
# write enable
create_hw_axi_txn write_txn21 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x0C]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn21]

after 500

### CTRL REG
# write disable
create_hw_axi_txn write_txn22 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x0C]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn22]
# reg address
create_hw_axi_txn write_txn23 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x04]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn23]
# data
create_hw_axi_txn write_txn24 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x08]] -len 1 -data {00009000}
run_hw_axi [get_hw_axi_txns write_txn24]
# write enable
create_hw_axi_txn write_txn25 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0x0C]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn25]

delete_hw_axi_txn [get_hw_axi_txns *]
