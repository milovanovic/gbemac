# PART is artix7 xc7a200tsbg484

#
####
#######
##########
#############
#################
## System level constraints

#set_property CFGBVS VCCO [current_design]
#set_property CONFIG_VOLTAGE 2.5 [current_design]


########## NO BOARD INFO SO IO NO PIN PLACEMENT ##########
#set_property IOSTANDARD  DIFF_HSTL_II_18  [get_ports clk_in_p]
#set_property IOSTANDARD  DIFF_HSTL_II_18  [get_ports clk_in_n]
set_property -dict { PACKAGE_PIN R4    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_34 Sch=sysclk
create_clock -add -name clk_in_p -period 10.00 -waveform {0 5} [get_ports {clk}]
set_input_jitter clk_in_p 0.050

#set_property IOSTANDARD  LVCMOS25 [get_ports glbl_rst]
#set_false_path -from [get_ports glbl_rst]

#### Module LEDs_8Bit constraints
#set_property IOSTANDARD  LVCMOS25 [get_ports activity_flash]
#set_property IOSTANDARD  LVCMOS25 [get_ports activity_flashn]
#set_property IOSTANDARD  LVCMOS25 [get_ports frame_error]
#set_property IOSTANDARD  LVCMOS25 [get_ports frame_errorn]
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS25 } [get_ports { activity_flash }]; #IO_L15P_T2_DQS_13 Sch=led[0]
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS25 } [get_ports { activity_flashn }]; #IO_L15N_T2_DQS_13 Sch=led[1]
#set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS25 } [get_ports { frame_error }]; #IO_L17P_T2_13 Sch=led[2]
#set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS25 } [get_ports { frame_errorn }]; #IO_L17N_T2_13 Sch=led[3]

#set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS25 } [get_ports { success }]; #IO_L5P_T0_13 Sch=led[7]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS25 } [get_ports { error }]; #IO_L14N_T2_SRCC_13 Sch=led[4]

#### Module Push_Buttons_4Bit constraints
#set_property IOSTANDARD  LVCMOS25 [get_ports update_speed]
#set_property IOSTANDARD  LVCMOS25 [get_ports config_board]
#set_property IOSTANDARD  LVCMOS25 [get_ports pause_req_s]
#set_property IOSTANDARD  LVCMOS25 [get_ports reset_error]
set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS25 } [get_ports { glbl_rst }]; #IO_L20N_T3_16 Sch=btnc
set_false_path -from [get_ports glbl_rst]
#set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS25 } [get_ports { fin_gen }]; #IO_L22N_T3_16 Sch=btnd
#set_false_path -from [get_ports fin_gen]
#set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS25 } [get_ports { config_board }]; #IO_L20P_T3_16 Sch=btnl
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS25 } [get_ports { pause_req_s }]; #IO_L6P_T0_16 Sch=btnr
#set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS25 } [get_ports { reset_error }]; #IO_0_16 Sch=btnu

#### Module DIP_Switches_4Bit constraints
#set_property IOSTANDARD  LVCMOS25 [get_ports mac_speed[0]]
#set_property IOSTANDARD  LVCMOS25 [get_ports mac_speed[1]]
#set_property IOSTANDARD  LVCMOS25 [get_ports gen_tx_data]
#set_property IOSTANDARD  LVCMOS25 [get_ports chk_tx_data]
#set_property -dict { PACKAGE_PIN E22  IOSTANDARD LVCMOS25 } [get_ports { mac_speed[0] }]; #IO_L22P_T3_16 Sch=sw[0]
#set_property -dict { PACKAGE_PIN F21  IOSTANDARD LVCMOS25 } [get_ports { mac_speed[1] }]; #IO_25_16 Sch=sw[1]
#set_property -dict { PACKAGE_PIN G21  IOSTANDARD LVCMOS25 } [get_ports { gen_tx_data }]; #IO_L24P_T3_16 Sch=sw[2]
#set_property -dict { PACKAGE_PIN G22  IOSTANDARD LVCMOS25 } [get_ports { chk_tx_data }]; #IO_L24N_T3_16 Sch=sw[3]

#set_property -dict { PACKAGE_PIN J16  IOSTANDARD LVCMOS12 } [get_ports { mem_reset }]; #IO_0_15 Sch=sw[5]
#set_property -dict { PACKAGE_PIN M17  IOSTANDARD LVCMOS12 } [get_ports { start_tcp }]; #IO_25_15 Sch=sw[7]

#set_property IOSTANDARD  LVCMOS25 [get_ports phy_resetn]
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { phy_resetn }]; #IO_25_34 Sch=eth_rst_b

#set_property IOSTANDARD  LVCMOS25 [get_ports serial_response]
#set_property IOSTANDARD  LVCMOS25 [get_ports tx_statistics_s]
#set_property IOSTANDARD  LVCMOS25 [get_ports rx_statistics_s]
#set_property -dict { PACKAGE_PIN AB22  IOSTANDARD LVCMOS33 } [get_ports { serial_response }]; #IO_L10N_T1_D15_14 Sch=ja[1]
#set_property -dict { PACKAGE_PIN AB21  IOSTANDARD LVCMOS33 } [get_ports { tx_statistics_s }]; #IO_L10P_T1_D14_14 Sch=ja[2]
#set_property -dict { PACKAGE_PIN AB20  IOSTANDARD LVCMOS33 } [get_ports { rx_statistics_s }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=ja[3]

#set_property IOSTANDARD  LVCMOS25 [get_ports mdc]
#set_property IOSTANDARD  LVCMOS25 [get_ports mdio]
set_property -dict { PACKAGE_PIN AA16  IOSTANDARD LVCMOS25 } [get_ports { mdc }]; #IO_L1N_T0_13 Sch=eth_mdc
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS25 } [get_ports { mdio }]; #IO_L1P_T0_13 Sch=eth_mdio

#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_rxd[3]]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_rxd[2]]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_rxd[1]]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_rxd[0]]
set_property -dict { PACKAGE_PIN AB16  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rxd[0] }]; #IO_L2P_T0_13 Sch=eth_rxd[0]
set_property -dict { PACKAGE_PIN AA15  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rxd[1] }]; #IO_L4P_T0_13 Sch=eth_rxd[1]
set_property -dict { PACKAGE_PIN AB15  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rxd[2] }]; #IO_L4N_T0_13 Sch=eth_rxd[2]
set_property -dict { PACKAGE_PIN AB11  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rxd[3] }]; #IO_L7P_T1_13 Sch=eth_rxd[3]

#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_txd[3]]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_txd[2]]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_txd[1]]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_txd[0]]
set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS25 } [get_ports { rgmii_txd[0] }]; #IO_L11N_T1_SRCC_13 Sch=eth_txd[0]
set_property -dict { PACKAGE_PIN W12   IOSTANDARD LVCMOS25 } [get_ports { rgmii_txd[1] }]; #IO_L12N_T1_MRCC_13 Sch=eth_txd[1]
set_property -dict { PACKAGE_PIN W11   IOSTANDARD LVCMOS25 } [get_ports { rgmii_txd[2] }]; #IO_L12P_T1_MRCC_13 Sch=eth_txd[2]
set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS25 } [get_ports { rgmii_txd[3] }]; #IO_L11P_T1_SRCC_13 Sch=eth_txd[3]

#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_tx_ctl]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_txc]
set_property -dict { PACKAGE_PIN AA14  IOSTANDARD LVCMOS25 } [get_ports { rgmii_txc }]; #IO_L5N_T0_13 Sch=eth_txck
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS25 } [get_ports { rgmii_tx_ctl }]; #IO_L10P_T1_13 Sch=eth_txctl

#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_rx_ctl]
#set_property IOSTANDARD  HSTL_I_18 [get_ports rgmii_rxc]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS25 } [get_ports { rgmii_rxc }]; #IO_L13P_T2_MRCC_13 Sch=eth_rxck
set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS25 } [get_ports { rgmii_rx_ctl }]; #IO_L10N_T1_13 Sch=eth_rxctl

