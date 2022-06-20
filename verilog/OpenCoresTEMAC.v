`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2022 04:35:54 PM
// Design Name: 
// Module Name: OpenCoresTEMAC
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


module OpenCoresTEMAC(
    
    input           Reset,
    input           Clk_125M,
    input           Clk_user,
    input           Clk_reg,
    
    output          Gtx_clk,
    input           Rx_clk,
    input           Tx_clk,
    output          Tx_er,
    output          Tx_en,
    output  [7:0]   Txd,
    input           Rx_er,
    input           Rx_dv,
    input   [7:0]   Rxd,
    input           Crs,
    input           Col,
    
    output          Mdo,                // MII Management Data Output
    output          MdoEn,              // MII Management Data Output Enable
    input           Mdi,
    output          Mdc,                     // MII Management Data Clock 
    
    input s_axis_tvalid,
    output s_axis_tready,
    input s_axis_tlast,
    input [31:0] s_axis_tdata,
    
    output m_axis_tvalid,
    input m_axis_tready,
    output [31:0] m_axis_tdata,
    output m_axis_tlast,
    
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
    input [15:0] packetSize
    );
    
    
wire Tx_mac_wa;
wire Tx_mac_wr;
wire [31:0]  Tx_mac_data;
wire [1:0]   Tx_mac_BE;
wire Tx_mac_sop;
wire Tx_mac_eop;

wire Rx_mac_ra;
wire Rx_mac_rd;
wire [31:0] Rx_mac_data;
wire [1:0] Rx_mac_BE;
wire Rx_mac_pa;
wire Rx_mac_sop;
wire Rx_mac_eop;

wire [31:0] rx_fifo_master_data;
wire rx_fifo_master_valid;
wire rx_fifo_master_ready;
wire rx_fifo_master_last;

reg Tx_mac_wr_reg;
reg [31:0]  Tx_mac_data_reg;
reg Tx_mac_sop_reg;
reg Tx_mac_eop_reg;
reg Rx_mac_rd_reg;
    
reg slave_last_reg;
reg Rx_mac_eop_reg;
reg tx_eop_sop;

wire full;
wire rx_fifo_ready;
    
MAC_top macTop(
                //system signals
    .Reset(Reset),
    .Clk_125M(Clk_125M),
    .Clk_user(Clk_user),
    .Clk_reg(Clk_reg),
                    //user interface 
    .Rx_mac_ra(Rx_mac_ra),
    .Rx_mac_rd(Rx_mac_rd),
    .Rx_mac_data(Rx_mac_data),
    .Rx_mac_BE(Rx_mac_BE),
    .Rx_mac_pa(Rx_mac_pa),
    .Rx_mac_sop(Rx_mac_sop),
    .Rx_mac_eop(Rx_mac_eop),
                    //user interface 
    .Tx_mac_wa(Tx_mac_wa),
    .Tx_mac_wr(Tx_mac_wr_reg && Tx_mac_wa),
    .Tx_mac_data(Tx_mac_data_reg),
    .Tx_mac_BE(Tx_mac_BE),//big endian
    .Tx_mac_sop(Tx_mac_sop_reg),
    .Tx_mac_eop(Tx_mac_eop_reg),
                    //pkg_lgth fifo
    .Pkg_lgth_fifo_rd(1'b0),
    .Pkg_lgth_fifo_ra(Pkg_lgth_fifo_ra),
    .Pkg_lgth_fifo_data(Pkg_lgth_fifo_data),
                    //Phy interface          
                    //Phy interface         
    .Gtx_clk(Gtx_clk),//used only in GMII mode
    .Rx_clk(Rx_clk),
    .Tx_clk(Tx_clk),//used only in MII mode
    .Tx_er(Tx_er),
    .Tx_en(Tx_en),
    .Txd(Txd),
    .Rx_er(Rx_er),
    .Rx_dv(Rx_dv),
    .Rxd(Rxd),
    .Crs(Crs),
    .Col(Col),
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


QueueLastGbemac1024 rx_data_fifo(
    .clock(Clk_user),
    .reset(Reset),
    .io_full(full),
    .io_deq_ready(m_axis_tready),
    .io_deq_valid(m_axis_tvalid),
    .io_deq_bits(m_axis_tdata),
    .io_enq_ready(rx_fifo_ready),
    .io_enq_valid(Rx_mac_pa),
    .io_enq_bits(Rx_mac_data),
    .io_enq_last(Rx_mac_eop),
    .io_deq_last(m_axis_tlast)
  );


assign Tx_mac_BE = 2'b00;


always @(posedge Clk_user) begin
    if(Reset)
        tx_eop_sop <= 1'b1; //1'b0;
    else if(Tx_mac_eop)
        tx_eop_sop <= 1'b1;
    else if(Tx_mac_sop)
        tx_eop_sop <= 1'b0;
end

assign Tx_mac_sop = tx_eop_sop && Tx_mac_wr && Tx_mac_wa;

always @(posedge Clk_user) begin
    if(Reset)
        Rx_mac_rd_reg <= 1'b0;
    else
        Rx_mac_rd_reg <= Rx_mac_ra;
end

always @(posedge Clk_user) begin
    if(Reset)
        Rx_mac_eop_reg <= 1'b0;
    else
        Rx_mac_eop_reg <= Rx_mac_eop;
end

assign Rx_mac_rd = ((Rx_mac_eop || Rx_mac_eop_reg) ? Rx_mac_ra : Rx_mac_rd_reg) && !full && rx_fifo_ready;

always @(posedge Clk_user) begin
    if(Reset)
        slave_last_reg <= 1'b0;
    else
        slave_last_reg <= s_axis_tlast && Tx_mac_wa;
end 

assign Tx_mac_eop = (s_axis_tlast && Tx_mac_wa) && !slave_last_reg;

always @(posedge Clk_user) begin
    if(Reset) begin
        Tx_mac_wr_reg <= 1'b0;
        Tx_mac_data_reg <= 1'b0;
        Tx_mac_sop_reg <= 1'b0;
        Tx_mac_eop_reg <= 1'b0;
    end
    else begin
        if(Tx_mac_wa) begin
            Tx_mac_wr_reg <= Tx_mac_wr;
            Tx_mac_data_reg <= Tx_mac_data;
            Tx_mac_sop_reg <= Tx_mac_sop;
        end
        if(Tx_mac_eop)
            Tx_mac_eop_reg <= 1'b1;
        else if(Tx_mac_wa)
            Tx_mac_eop_reg <= 1'b0;
    end
end

assign Tx_mac_data = s_axis_tdata;
assign Tx_mac_wr = s_axis_tvalid;
assign s_axis_tready = Tx_mac_wa;



endmodule
