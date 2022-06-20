`timescale 1ns/100ps

/*Gigabit, full-duplex */


module sdr_ddr_converter_xilinx(
        
        input wire reset_n,
        input wire rx_clk,
        //input wire rx_clk_dly,
        input wire [3:0] din,
        input wire rx_ctl,
        input wire tx_clk,
        input wire [7:0] txd,
        input wire tx_er,
        input wire tx_en,
        
        output wire [3:0] dout_a,
        output wire [3:0] dout_b,
        output wire rx_ctl_a,
        output wire rx_ctl_b,
        output wire [3:0] td,
        output wire tx_ctl

    );
    
    reg [3:0] ireg_pos;
    reg [3:0] ireg_neg;
    reg [3:0] din_clk_a;
    reg [3:0] din_clk_b;
    reg ireg_ctl_pos;
    reg ireg_ctl_neg;
    reg rx_ctrl_a;
    reg rx_ctrl_b;
    
    always @(posedge rx_clk) begin
        ireg_pos <= din;
        ireg_ctl_pos <= rx_ctl;
    end
    
    always @(negedge rx_clk) begin
        ireg_neg <= din;
        ireg_ctl_neg <= rx_ctl;
    end
    
    always @(posedge rx_clk) begin
        din_clk_a <= ireg_pos;
        din_clk_b <= ireg_neg;
        rx_ctrl_a <= ireg_ctl_pos;
        rx_ctrl_b <= ireg_ctl_neg;
    end
    
    assign dout_a = din_clk_a;
    assign dout_b = din_clk_b;
    assign rx_ctl_a = rx_ctrl_a;
    assign rx_ctl_b = rx_ctrl_b;
    
    ODDR #( //ODDR
         //.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
         .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) U_TX_OUT0 (
         .Q(td[0]),   // 1-bit DDR output
         .C(tx_clk),   // 1-bit clock input
         .CE(1'b1), // 1-bit clock enable input
         .D1(txd[0]), // 1-bit data input (positive edge)
         .D2(txd[4]), // 1-bit data input (negative edge)
         //.R(~reset_n),   // 1-bit reset
         .R(1'b0),   // 1-bit reset
         .S(1'b0)    // 1-bit set
      );
      
      ODDR #( //ODDR
         //.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
         .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
         .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) U_TX_OUT1 (
         .Q(td[1]),   // 1-bit DDR output
         .C(tx_clk),   // 1-bit clock input
         .CE(1'b1), // 1-bit clock enable input
         .D1(txd[1]), // 1-bit data input (positive edge)
         .D2(txd[5]), // 1-bit data input (negative edge)
         //.R(~reset_n),   // 1-bit reset
         .R(1'b0),   // 1-bit reset
         .S(1'b0)    // 1-bit set
      );
      
      ODDR #( //ODDR
         //.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
         .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
         .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) U_TX_OUT2 (
         .Q(td[2]),   // 1-bit DDR output
         .C(tx_clk),   // 1-bit clock input
         .CE(1'b1), // 1-bit clock enable input
         .D1(txd[2]), // 1-bit data input (positive edge)
         .D2(txd[6]), // 1-bit data input (negative edge)
         //.R(~reset_n),   // 1-bit reset
         .R(1'b0),   // 1-bit reset
         .S(1'b0)    // 1-bit set
      );
      
      ODDR #( //ODDR
         //.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
         .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
         .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) U_TX_OUT3 (
         .Q(td[3]),   // 1-bit DDR output
         .C(tx_clk),   // 1-bit clock input
         .CE(1'b1), // 1-bit clock enable input
         .D1(txd[3]), // 1-bit data input (positive edge)
         .D2(txd[7]), // 1-bit data input (negative edge)
         //.R(~reset_n),   // 1-bit reset
         .R(1'b0),   // 1-bit reset
         .S(1'b0)    // 1-bit set
      );
      
      ODDR #( //ODDR
         //.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
         .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
         .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
         .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) U_TX_CTL (
         .Q(tx_ctl),   // 1-bit DDR output
         .C(tx_clk),   // 1-bit clock input
         .CE(1'b1), // 1-bit clock enable input
         .D1(tx_en), // 1-bit data input (positive edge)
         .D2(tx_er), // 1-bit data input (negative edge)
         //.R(~reset_n),   // 1-bit reset
         .R(1'b0),   // 1-bit reset
         .S(1'b0)    // 1-bit set
      );
    
    
    
    
    endmodule
