`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2022 11:11:32 AM
// Design Name: 
// Module Name: topModule
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


module topModule(
    
    input wire clk,
    input wire glbl_rst,
    //input wire start,
    output        phy_resetn,
    output [3:0]  rgmii_txd,
    output        rgmii_tx_ctl,
    output        rgmii_txc,
    input  [3:0]  rgmii_rxd,
    input         rgmii_rx_ctl,
    input         rgmii_rxc,
    inout         mdio,
    output        mdc
    
    );

wire m_axi_awready;
wire m_axi_awvalid;
wire m_axi_awid;
wire [31:0] m_axi_awaddr;
wire [7:0]  m_axi_awlen;
wire [2:0]  m_axi_awsize;
wire [1:0]  m_axi_awburst;
wire m_axi_awlock;
wire [3:0]  m_axi_awcache;
wire [2:0]  m_axi_awprot;
wire [3:0]  m_axi_awqos;
wire m_axi_wready;
wire m_axi_wvalid;
wire [31:0] m_axi_wdata;
wire [3:0]  m_axi_wstrb;
wire m_axi_wlast;
wire m_axi_bready;
wire m_axi_bvalid;
wire m_axi_bid;
wire [1:0]  m_axi_bresp;
wire m_axi_arready;
wire m_axi_arvalid;
wire m_axi_arid;
wire [31:0] m_axi_araddr;
wire [7:0]  m_axi_arlen;
wire [2:0]  m_axi_arsize;
wire [1:0]  m_axi_arburst;
wire m_axi_arlock;
wire [3:0]  m_axi_arcache;
wire [2:0]  m_axi_arprot;
wire [3:0]  m_axi_arqos;
wire m_axi_rready;
wire m_axi_rvalid;
wire m_axi_rid;
wire [31:0] m_axi_rdata;
wire [1:0]  m_axi_rresp;
wire m_axi_rlast;

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

wire clk125, clk125_90, clk5;

wire tx_streaming_valid;
wire tx_streaming_ready;
wire tx_streaming_last;
wire [31:0] tx_streaming_data;

reg [31:0] stream_data_reg;

wire [4:0]  txHwmark;
wire [4:0]  txLwmark;
wire        pauseFrameSendEn;
wire [15:0] pauseQuantaSet;
wire        macTxAddEn;
wire        fullDuplex;
wire [3:0]  maxRetry;
wire [5:0]  ifgSet;
wire [7:0]  macTxAddPromData;
wire [2:0]  macTxAddPromAdd;
wire        macTxAddPromWr;
wire        txPauseEn;
wire        xOffCpu;
wire        xOnCpu;
wire        macRxAddChkEn;
wire [7:0]  macRxAddPromData;
wire [2:0]  macRxAddPromAdd;
wire        macRxAddPromWr;
wire        broadcastFilterEn;
wire [15:0] broadcastBucketDepth;
wire [15:0] broadcastBucketInterval;
wire        rxAppendCrc;
wire [4:0]  rxHwmark;
wire [4:0]  rxLwmark;
wire        crcCheckEn;
wire [5:0]  rxIfgSet;
wire [15:0] rxMaxLength;
wire [6:0]  rxMinLength;
wire [5:0]  cpuRdAddr;
wire        cpuRdApply;
wire        lineLoopEn;
wire [2:0]  speed;
wire [7:0]  divider;
wire [15:0] ctrlData;
wire [4:0]  rgAd;
wire [4:0]  fiAd;
wire        writeCtrlData;
wire        noPreamble;
wire [15:0] packetSize;
wire [47:0] srcMac;
wire [31:0] srcIp;
wire [15:0] srcPort;
wire [47:0] dstMac;
wire [31:0] dstIp;
wire [15:0] dstPort;
wire ctrlStart;
wire ctrlStop;
wire ctrlRst;


jtag_axi_0 jtag2axi (
  //.aclk(clk5),                    // input wire aclk
  .aclk(clk),                    // input wire aclk
  .aresetn(!glbl_rst),              // input wire aresetn
  .m_axi_awid(m_axi_awid),        // output wire [0 : 0] m_axi_awid
  .m_axi_awaddr(m_axi_awaddr),    // output wire [31 : 0] m_axi_awaddr
  .m_axi_awlen(m_axi_awlen),      // output wire [7 : 0] m_axi_awlen
  .m_axi_awsize(m_axi_awsize),    // output wire [2 : 0] m_axi_awsize
  .m_axi_awburst(m_axi_awburst),  // output wire [1 : 0] m_axi_awburst
  .m_axi_awlock(m_axi_awlock),    // output wire m_axi_awlock
  .m_axi_awcache(m_axi_awcache),  // output wire [3 : 0] m_axi_awcache
  .m_axi_awprot(m_axi_awprot),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awqos(m_axi_awqos),      // output wire [3 : 0] m_axi_awqos
  .m_axi_awvalid(m_axi_awvalid),  // output wire m_axi_awvalid
  .m_axi_awready(m_axi_awready),  // input wire m_axi_awready
  .m_axi_wdata(m_axi_wdata),      // output wire [31 : 0] m_axi_wdata
  .m_axi_wstrb(m_axi_wstrb),      // output wire [3 : 0] m_axi_wstrb
  .m_axi_wlast(m_axi_wlast),      // output wire m_axi_wlast
  .m_axi_wvalid(m_axi_wvalid),    // output wire m_axi_wvalid
  .m_axi_wready(m_axi_wready),    // input wire m_axi_wready
  .m_axi_bid(m_axi_bid),          // input wire [0 : 0] m_axi_bid
  .m_axi_bresp(m_axi_bresp),      // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid(m_axi_bvalid),    // input wire m_axi_bvalid
  .m_axi_bready(m_axi_bready),    // output wire m_axi_bready
  .m_axi_arid(m_axi_arid),        // output wire [0 : 0] m_axi_arid
  .m_axi_araddr(m_axi_araddr),    // output wire [31 : 0] m_axi_araddr
  .m_axi_arlen(m_axi_arlen),      // output wire [7 : 0] m_axi_arlen
  .m_axi_arsize(m_axi_arsize),    // output wire [2 : 0] m_axi_arsize
  .m_axi_arburst(m_axi_arburst),  // output wire [1 : 0] m_axi_arburst
  .m_axi_arlock(m_axi_arlock),    // output wire m_axi_arlock
  .m_axi_arcache(m_axi_arcache),  // output wire [3 : 0] m_axi_arcache
  .m_axi_arprot(m_axi_arprot),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arqos(m_axi_arqos),      // output wire [3 : 0] m_axi_arqos
  .m_axi_arvalid(m_axi_arvalid),  // output wire m_axi_arvalid
  .m_axi_arready(m_axi_arready),  // input wire m_axi_arready
  .m_axi_rid(m_axi_rid),          // input wire [0 : 0] m_axi_rid
  .m_axi_rdata(m_axi_rdata),      // input wire [31 : 0] m_axi_rdata
  .m_axi_rresp(m_axi_rresp),      // input wire [1 : 0] m_axi_rresp
  .m_axi_rlast(m_axi_rlast),      // input wire m_axi_rlast
  .m_axi_rvalid(m_axi_rvalid),    // input wire m_axi_rvalid
  .m_axi_rready(m_axi_rready)    // output wire m_axi_rready
);

  clk_wiz_0 clkWiz
   (
    // Clock out ports
    .clk_out1(clk125),     // output clk_out1
    .clk_out2(clk125_90),     // output clk_out2
    .clk_out3(clk5),     // output clk_out3
    // Status and control signals
    .reset(glbl_rst), // input reset
   // Clock in ports
    .clk_in1(clk)
    );      // input clk_in1


GbemacWrapperBlock GbemacWrapper(
  .clock(clk),
  .reset(glbl_rst),
  .io_clk125(clk125),
  .io_clk125_90(clk125_90),
  .io_clk5(clk5),
  .io_phy_resetn(phy_resetn),
  .io_rgmii_txd(rgmii_txd),
  .io_rgmii_tx_ctl(rgmii_tx_ctl),
  .io_rgmii_txc(rgmii_txc),
  .io_rgmii_rxd(rgmii_rxd),
  .io_rgmii_rx_ctl(rgmii_rx_ctl),
  .io_rgmii_rxc(rgmii_rxc),
  .io_mdio(mdio),
  .io_mdc(mdc),
  .ioMem_0_aw_ready(m_axi_awready),
  .ioMem_0_aw_valid(m_axi_awvalid),
  .ioMem_0_aw_bits_id(m_axi_awid),
  .ioMem_0_aw_bits_addr(m_axi_awaddr),
  .ioMem_0_aw_bits_len(m_axi_awlen),
  .ioMem_0_aw_bits_size(m_axi_awsize),
  .ioMem_0_aw_bits_burst(m_axi_awburst),
  .ioMem_0_aw_bits_lock(m_axi_awlock),
  .ioMem_0_aw_bits_cache(m_axi_awcache),
  .ioMem_0_aw_bits_prot(m_axi_awprot),
  .ioMem_0_aw_bits_qos(m_axi_awqos),
  .ioMem_0_w_ready(m_axi_wready),
  .ioMem_0_w_valid(m_axi_wvalid),
  .ioMem_0_w_bits_data(m_axi_wdata),
  .ioMem_0_w_bits_strb(m_axi_wstrb),
  .ioMem_0_w_bits_last(m_axi_wlast),
  .ioMem_0_b_ready(m_axi_bready),
  .ioMem_0_b_valid(m_axi_bvalid),
  .ioMem_0_b_bits_id(m_axi_bid),
  .ioMem_0_b_bits_resp(m_axi_bresp),
  .ioMem_0_ar_ready(m_axi_arready),
  .ioMem_0_ar_valid(m_axi_arvalid),
  .ioMem_0_ar_bits_id(m_axi_arid),
  .ioMem_0_ar_bits_addr(m_axi_araddr),
  .ioMem_0_ar_bits_len(m_axi_arlen),
  .ioMem_0_ar_bits_size(m_axi_arsize),
  .ioMem_0_ar_bits_burst(m_axi_arburst),
  .ioMem_0_ar_bits_lock(m_axi_arlock),
  .ioMem_0_ar_bits_cache(m_axi_arcache),
  .ioMem_0_ar_bits_prot(m_axi_arprot),
  .ioMem_0_ar_bits_qos(m_axi_arqos),
  .ioMem_0_r_ready(m_axi_rready),
  .ioMem_0_r_valid(m_axi_rvalid),
  .ioMem_0_r_bits_id(m_axi_rid),
  .ioMem_0_r_bits_data(m_axi_rdata),
  .ioMem_0_r_bits_resp(m_axi_rresp),
  .ioMem_0_r_bits_last(m_axi_rlast),
  .in_0_ready(tx_streaming_ready),
  .in_0_valid(tx_streaming_valid),
  .in_0_bits_data(tx_streaming_data),
  .in_0_bits_last(tx_streaming_last)
);






reg [15:0] pause_counter;
reg [4:0] valid_counter;

assign tx_streaming_valid = (((pause_counter == 1'b0) || (pause_counter == 16'd2048)) && (valid_counter == 5'b11111)) ? tx_streaming_ready : 1'b0;
assign tx_streaming_data = stream_data_reg;


always @(posedge clk) begin
    if(glbl_rst)
        pause_counter <= 1'b0;
    else if(((stream_data_reg == 32'h00001C55) || (stream_data_reg == 32'h00001C56)) && (pause_counter < 16'd2048))
        pause_counter <= pause_counter + 1'b1;
    else if(((stream_data_reg == 32'h00001C88) || (stream_data_reg == 32'h00001C89)) && (pause_counter < 16'd2048))
        pause_counter <= pause_counter + 1'b1;
    else if(pause_counter >= 16'd2048)
        pause_counter <= 1'b0;
end


always @(posedge clk) begin
    if(glbl_rst)
        stream_data_reg <= 1'b0;
    else if(tx_streaming_valid && ((pause_counter == 1'b0) || (pause_counter == 16'd2048)))
        stream_data_reg <= stream_data_reg + 1'b1;
end

always @(posedge clk) begin
    if(glbl_rst)
        valid_counter <= 1'b0;
    else 
        valid_counter <= valid_counter + 1'b1;
end
  
endmodule
