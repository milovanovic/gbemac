reset_hw_axi [get_hw_axis hw_axi_1]

set baseAddrGbemac 0x20000000

# stop data streaming and terminate TCP connection
create_hw_axi_txn write_txn1 [get_hw_axis hw_axi_1] -type WRITE -address [format %08x [expr $baseAddrGbemac + 0xC0]] -len 1 -data {00000001}
run_hw_axi [get_hw_axi_txns write_txn1]

delete_hw_axi_txn [get_hw_axi_txns *]
