`timescale 1ns/100ps

/*Gigabit, full-duplex */


module gmii_to_rgmii_xilinx(
        
        input wire reset_n,
    
    // gmii interface
        input wire [7:0] gmii_txd,
        input wire gmii_tx_en,
        input wire gmii_tx_er,
        input wire gmii_tx_clk,
        input wire gmii_tx_clk90,
        output wire [7:0] gmii_rxd,
        output wire gmii_rx_dv,
        output wire gmii_rx_er,
        output wire gmii_rx_clk,
    
    // rgmii interface
        output wire [3:0] rgmii_txd,
        output wire rgmii_tx_ctl,
        output wire rgmii_txc,
        input wire [3:0] rgmii_rxd,
        input wire rgmii_rx_ctl,
        input wire rgmii_rxc //,

    );
    
    reg [7:0] txd_buf;
    reg tx_en_buf;
    reg tx_er_buf;
    reg [7:0] rxd_buf;
    reg rx_dv_buf;
    reg rx_er_buf;
    
    wire tx_er_gen;
    wire [3:0] rx_out_a;
    wire [3:0] rx_out_b;
    wire rx_ctl_a;
    wire rx_ctl_b;
    
    wire rx_clk_dly;
    assign rx_clk_dly = rgmii_rxc;

    
    
    always @(posedge gmii_tx_clk or negedge reset_n) begin
        if(!reset_n) begin
            tx_en_buf <= 1'b0;
            tx_er_buf <= 1'b0;
            txd_buf <= 8'h00;
        end
        else begin
            tx_en_buf <= gmii_tx_en;
            tx_er_buf <= gmii_tx_er;
            txd_buf <= gmii_txd;
        end
    end
    
    assign tx_er_gen = tx_en_buf ^ tx_er_buf;
    
    always @(posedge rx_clk_dly or negedge reset_n) begin
        if(!reset_n) begin
            rxd_buf     <= 8'h00;
            rx_dv_buf   <= 1'b0;
            rx_er_buf   <= 1'b0;
        end else begin
            rxd_buf     <= {rx_out_b,rx_out_a};
            rx_dv_buf   <= rx_ctl_a;
            rx_er_buf   <= rx_ctl_a ^ rx_ctl_b;
        end
    end
    
    assign gmii_rxd = rxd_buf;
    assign gmii_rx_dv = rx_dv_buf;
    assign gmii_rx_er = rx_er_buf;

    assign gmii_rx_clk = rx_clk_dly;
    
    ODDR #( //ODDR
         //.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
         .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) U_TX_CLK (
         .Q(rgmii_txc),   // 1-bit DDR output
         .C(gmii_tx_clk90),   // 1-bit clock input
         .CE(1'b1), // 1-bit clock enable input
         .D1(1'b1), // 1-bit data input (positive edge)
         .D2(1'b0), // 1-bit data input (negative edge)
         //.R(~reset_n),   // 1-bit reset
         .R(1'b0),   // 1-bit reset
         .S(1'b0)    // 1-bit set
      );
    

    sdr_ddr_converter_xilinx sdr_ddr_conv(
        .reset_n(reset_n),
        .rx_clk(rx_clk_dly),
        .din(rgmii_rxd),
        .rx_ctl(rgmii_rx_ctl),
        .tx_clk(gmii_tx_clk),
        .txd(txd_buf),
        .tx_er(tx_er_gen),
        .tx_en(tx_en_buf),
        .dout_a(rx_out_a),
        .dout_b(rx_out_b),
        .rx_ctl_a(rx_ctl_a),
        .rx_ctl_b(rx_ctl_b),
        .td(rgmii_txd),
        .tx_ctl(rgmii_tx_ctl)
    );


endmodule
