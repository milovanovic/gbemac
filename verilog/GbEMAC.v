`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2022 03:48:03 PM
// Design Name: 
// Module Name: GbEMAC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GbEMAC (
    input clk,
    input clk125,
    input clk125_90,
    input clk5,
    input reset,
    
    input [31:0] tx_streaming_data,
    input tx_streaming_valid,
    input tx_streaming_last,
    output tx_streaming_ready, //fifo buffer for data streaming, checksum is calculated after xx bytes have arrived, then all those bytes are sent as a packet
    
    output        phy_resetn,
    output [3:0]  rgmii_txd,
    output        rgmii_tx_ctl,
    output        rgmii_txc,
    input  [3:0]  rgmii_rxd,
    input         rgmii_rx_ctl,
    input         rgmii_rxc,
    inout         mdio,
    output        mdc,
    
    input start_tcp,
    input fin_gen,

    input [4:0]  txHwmark,
    input [4:0]  txLwmark,
    input        pauseFrameSendEn,
    input [15:0] pauseQuantaSet,
    input        macTxAddEn,
    input        fullDuplex,
    input [3:0]  maxRetry,
    input [5:0]  ifgSet,
    input [7:0]  macTxAddPromData,
    input [2:0]  macTxAddPromAdd,
    input        macTxAddPromWr,
    input        txPauseEn,
    input        xOffCpu,
    input        xOnCpu,
    input        macRxAddChkEn,
    input [7:0]  macRxAddPromData,
    input [2:0]  macRxAddPromAdd,
    input        macRxAddPromWr,
    input        broadcastFilterEn,
    input [15:0] broadcastBucketDepth,
    input [15:0] broadcastBucketInterval,
    input        rxAppendCrc,
    input [4:0]  rxHwmark,
    input [4:0]  rxLwmark,
    input        crcCheckEn,
    input [5:0]  rxIfgSet,
    input [15:0] rxMaxLength,
    input [6:0]  rxMinLength,
    input [5:0]  cpuRdAddr,
    input        cpuRdApply,
    input        lineLoopEn,
    input [2:0]  speed,
    input [7:0]  divider,
    input [15:0] ctrlData,
    input [4:0]  rgAd,
    input [4:0]  fiAd,
    input        writeCtrlData,
    input        noPreamble,
    input [15:0] packetSize,
    input [47:0] srcMac,
    input [31:0] srcIp,
    input [15:0] srcPort,
    input [47:0] dstMac,
    input [31:0] dstIp,
    input [15:0] dstPort
);


wire mdo, mdi, mdoEn;

wire [7:0] gmii_txd;
wire gmii_tx_en;
wire gmii_tx_er;
wire gmii_tx_clk;
wire gmii_tx_clk90;
wire [7:0] gmii_rxd;
wire gmii_rx_dv;
wire gmii_rx_er;
wire gmii_rx_clk;

wire [31:0] tx_data;
wire tx_valid;
wire tx_ready;
wire tx_last;

wire [31:0] rx_data;
wire rx_valid;
wire rx_ready;
wire rx_last;

wire gtxClk;


gmii_to_rgmii_xilinx gmii2rgmii(
        
    .reset_n(!reset),
    
    // gmii interface
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),
    .gmii_tx_clk(clk125),
    .gmii_tx_clk90(clk125_90),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_rx_clk(gmii_rx_clk),
    
    // rgmii interface
    .rgmii_txd(rgmii_txd),
    .rgmii_tx_ctl(rgmii_tx_ctl),
    .rgmii_txc(rgmii_txc),
    .rgmii_rxd(rgmii_rxd),
    .rgmii_rx_ctl(rgmii_rx_ctl),
    .rgmii_rxc(rgmii_rxc) //,
    );
    
assign mdio = mdoEn ? mdo: 1'bz;
assign phy_resetn = 1'b1;


packet_creation_tcp protocol_ctrl (
    .clk(clk),
    .reset(reset),
    .slave_data(rx_data),
    .slave_valid(rx_valid),
    .slave_last(rx_last),
    .slave_ready(rx_ready),
    .master_data(tx_data),
    .master_valid(tx_valid),
    .master_ready(tx_ready),
    .master_last(tx_last),
    
    .start_tcp(start_tcp),
    .fin_gen(fin_gen),
    
    .srcMac(srcMac),
    .srcIp(srcIp),
    .srcPort(srcPort),
    .dstMac(dstMac),
    .dstIp(dstIp),
    .dstPort(dstPort),
    .packetSize(packetSize),
    
    .tx_streaming_data(tx_streaming_data),
    .tx_streaming_valid(tx_streaming_valid),
    .tx_streaming_last(tx_streaming_last),
    .tx_streaming_ready(tx_streaming_ready)
    );
    
OpenCoresTEMAC temac(
                //system signals
    .Reset(reset),
    .Clk_125M(clk125),
    .Clk_user(clk),
    .Clk_reg(clk5),
                    //user interface 
    .s_axis_tvalid(tx_valid),
    .s_axis_tready(tx_ready),
    .s_axis_tlast(tx_last),
    .s_axis_tdata(tx_data),
    
    .m_axis_tvalid(rx_valid),
    .m_axis_tready(rx_ready),
    .m_axis_tdata(rx_data),
    .m_axis_tlast(rx_last),        
                    //Phy interface         
    .Gtx_clk(gtxClk),//used only in GMII mode
    .Rx_clk(gmii_rx_clk),
    .Tx_clk(1'b0),//used only in MII mode
    .Tx_er(gmii_tx_er),
    .Tx_en(gmii_tx_en),
    .Txd(gmii_txd),
    .Rx_er(gmii_rx_er),
    .Rx_dv(gmii_rx_dv),
    .Rxd(gmii_rxd),
    .Crs(1'b0),
    .Col(1'b0),
                    //mdx
    .Mdo(mdo),                // MII Management Data Output
    .MdoEn(mdoEn),              // MII Management Data Output Enable
    .Mdi(mdi),
    .Mdc(mdc),                     // MII Management Data Clock
    
    .txHwmark(txHwmark),
    .txLwmark(txLwmark),
    .pauseFrameSendEn(pauseFrameSendEn),
    .pauseQuantaSet(pauseQuantaSet),
    .macTxAddEn(macTxAddEn),
    .fullDuplex(fullDuplex),
    .maxRetry(maxRetry),
    .ifgSet(ifgSet),
    .macTxAddPromData(macTxAddPromData),
    .macTxAddPromAdd(macTxAddPromAdd),
    .macTxAddPromWr(macTxAddPromWr),
    .txPauseEn(txPauseEn),
    .xOffCpu(xOffCpu),
    .xOnCpu(xOnCpu),
    .macRxAddChkEn(macRxAddChkEn),
    .macRxAddPromData(macRxAddPromData),
    .macRxAddPromAdd(macRxAddPromAdd),
    .macRxAddPromWr(macRxAddPromWr),
    .broadcastFilterEn(broadcastFilterEn),
    .broadcastBucketDepth(broadcastBucketDepth),
    .broadcastBucketInterval(broadcastBucketInterval),
    .rxAppendCrc(rxAppendCrc),
    .rxHwmark(rxHwmark),
    .rxLwmark(rxLwmark),
    .crcCheckEn(crcCheckEn),
    .rxIfgSet(rxIfgSet),
    .rxMaxLength(rxMaxLength),
    .rxMinLength(rxMinLength),
    .cpuRdAddr(cpuRdAddr),
    .cpuRdApply(cpuRdApply),
    .lineLoopEn(lineLoopEn),
    .speed(speed),
    .divider(divider),
    .ctrlData(ctrlData),
    .rgAd(rgAd),
    .fiAd(fiAd),
    .writeCtrlData(writeCtrlData),
    .noPreamble(noPreamble),
    .packetSize(packetSize)

);


endmodule

