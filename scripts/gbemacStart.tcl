reset_hw_axi [get_hw_axis hw_axi_1]

set baseAddrGbemac 0x20000000

# reset
create_hw_axi_txn write_txn1 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xC4]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn1]
# reset control start
create_hw_axi_txn write_txn2 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xBC]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn2]
# reset control stop
create_hw_axi_txn write_txn3 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xC0]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn3]
# release reset
create_hw_axi_txn write_txn4 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xC4]] -len 1 -data {00000000}
run_hw_axi [get_hw_axi_txns write_txn4]

# initiate TCP connection and start data streaming
create_hw_axi_txn write_txn5 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xBC]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn5]

delete_hw_axi_txn [get_hw_axi_txns *]
