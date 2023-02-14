`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2022 03:48:03 PM
// Design Name: 
// Module Name: packet_creation_udp
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

module packet_creation_udp (
    input clk,
    input reset,
    input [31:0] slave_data,
    input slave_valid,
    input slave_last,
    output slave_ready,
    output [31:0] master_data,
    output master_valid,
    input master_ready,
    output master_last,
    input [31:0] tx_streaming_data,
    input tx_streaming_valid,
    input tx_streaming_last,
    output tx_streaming_ready,
    output [31:0] rx_streaming_data,
    output rx_streaming_valid,
    output rx_streaming_last,
    input rx_streaming_ready,
    
    input [15:0] packetSize,
    input [47:0] srcMac,
    input [31:0] srcIp,
    input [15:0] srcPort,
    input [47:0] dstMac,
    input [31:0] dstIp,
    input [15:0] dstPort

);
    
    reg [15:0] PACKET_SIZE;
    reg [47:0] SRC_MAC;
    reg [31:0] SRC_IP;
    reg [15:0] SRC_PORT;
    reg [47:0] DST_MAC;
    reg [31:0] DST_IP;
    reg [15:0] DST_PORT;
    
    reg [15:0] MAC_LENGTH;
    reg [15:0] UDP_LENGTH;
    
    reg [47:0] dest_mac_arp;
    reg [31:0] dest_ip_arp;
    
    reg [3:0] reply_arp_counter;
    reg [3:0] rx_arp_counter;
    reg [3:0] rx_arp_counter_dl;
    
    wire [31:0] internal_data_rx;
    wire internal_valid_rx;
    wire internal_last_rx;
    wire internal_ready_rx;
    
    wire [31:0] internal_data_reply;
    wire internal_valid_reply;
    wire internal_last_reply;
    wire internal_ready_reply;
    
    reg [31:0] reply_tx_data;
    reg reply_tx_valid;
    reg reply_tx_last;
    
    wire [13:0] fifo_tx_stream_data_count;
    
    wire [15:0] lower_bytes_rx;
    wire [15:0] higher_bytes_rx;
    
    wire rx_arp_started;
    reg rx_arp_started_reg;
    reg error_rx_arp;
    
    reg reply_arp_requested, reply_arp_requested_dl;
    
    reg arp_active;
    
    reg [47:0] dest_mac_udp;
    reg [31:0] dest_ip_udp;
    
    reg [15:0] tx_udp_counter;

    reg [15:0] udp_payload_length, udp_total_length, udp_total_length_divided, tx_packet_length;
    
    reg [15:0] header_checksum;
    reg [31:0] header_checksum_temp1, header_checksum_temp2;
    
    wire stream_valid_internal;
    wire stream_ready_internal;
    wire [31:0] stream_data_internal;
    wire stream_last_internal;
    
    reg streaming_started;
    
    wire full_reply, full8192, full_rx;
    
    reg [15:0] counter_in1, counter_in2, counter_in_out;
    reg odd_package_arrived, even_package_arrived, first_package_out;
    
    wire tx_streaming_ready_internal;
    
    reg [15:0] rx_udp_counter;
    reg error_rx_udp;
    reg [15:0] rx_udp_length;
    reg [15:0] rx_udp_packet_size;
    reg [15:0] rx_udp_total_length_shifted;
    wire rx_udp_started;
    reg rx_udp_started_reg;
    
  
  QueueLastGbemac2048 rx_fifo(
    .clock(clk),
    .reset(reset),
    .io_full(full_rx),
    .io_deq_ready(internal_ready_rx),
    .io_deq_valid(internal_valid_rx),
    .io_deq_bits(internal_data_rx),
    .io_enq_ready(slave_ready),
    .io_enq_valid(slave_valid),
    .io_enq_bits(slave_data),
    .io_enq_last(slave_last),
    .io_deq_last(internal_last_rx)
  );
    
    //assign internal_ready_rx = 1'b1;
    
    always @(posedge clk) begin
        if(reset) begin
            SRC_MAC <= 1'b0;
            SRC_IP <= 1'b0;
            SRC_PORT <= 1'b0;
            DST_MAC <= 1'b0;
            DST_IP <= 1'b0;
            DST_PORT <= 1'b0;
            PACKET_SIZE <= 1'b0;
            MAC_LENGTH <= 1'b0;
            UDP_LENGTH <= 1'b0;
        end
        else begin
            SRC_MAC <= srcMac;
            SRC_IP <= srcIp;
            SRC_PORT <= srcPort;
            DST_MAC <= dstMac;
            DST_IP <= dstIp;
            DST_PORT <= dstPort;
            PACKET_SIZE <= packetSize;
            MAC_LENGTH <= PACKET_SIZE + 16'd30; //28
            UDP_LENGTH <= PACKET_SIZE + 16'd10; //8
            //UDP_LENGTH <= PACKET_SIZE + 16'd8; //8
        end
    end
    
    /*************************************** ARP ****************************************************/
    
    always @(posedge clk) begin
        if(reset)
        //if(reset || error_rx_arp)
            rx_arp_started_reg <= 1'b0;
        else if(rx_arp_started)
            rx_arp_started_reg <= 1'b1;
        else if((rx_arp_counter == 4'd10) && internal_valid_rx)
            rx_arp_started_reg <= 1'b0;
        else if(error_rx_arp)
            rx_arp_started_reg <= 1'b0;
    end
    
    //assign rx_arp_started = internal_valid_rx && ((internal_data_rx == 32'hffffffff) || (internal_data_rx == SRC_MAC[47:16]));
    assign rx_arp_started = internal_valid_rx && ((internal_data_rx == 32'hffffffff) || (internal_data_rx == SRC_MAC[47:16])) && (rx_arp_counter == 4'd0);
    
    always @(posedge clk) begin
        if(reset) begin
            rx_arp_counter <= 1'b0;
            dest_mac_arp <= 1'b0;
            dest_ip_arp <= 1'b0;
            error_rx_arp <= 1'b0;
        end
        else begin
            if (internal_valid_rx && (rx_arp_started || rx_arp_started_reg) && (rx_arp_counter < 4'd10))
                rx_arp_counter <= rx_arp_counter + 1'b1;
            else if (((rx_arp_counter == 4'd10) && internal_valid_rx) || error_rx_arp || internal_last_rx)
            //else if (((rx_arp_counter == 4'd10) && internal_valid_rx) || error_rx_arp) // || internal_last_rx)
                rx_arp_counter <= 1'b0;
                
            if(rx_arp_counter == 5)
                dest_mac_arp[47:32] <= lower_bytes_rx;
            else if(rx_arp_counter == 6)
                dest_mac_arp[31:0] <= internal_data_rx;
            
            if(rx_arp_counter == 7)
                dest_ip_arp[31:0] <= internal_data_rx;

            if(internal_valid_rx && (rx_arp_counter == 4'd0) && !((internal_data_rx == 32'hffffffff) || (internal_data_rx == SRC_MAC[47:16])))
                error_rx_arp <= 1'b1;
            else if(internal_valid_rx && (rx_arp_counter == 4'd1) && !((higher_bytes_rx == 16'hffff) || (higher_bytes_rx == SRC_MAC[15:0])))
                error_rx_arp <= 1'b1;
            else if(internal_valid_rx && (rx_arp_counter == 4'd3) && !(internal_data_rx == 32'h08060001))
                error_rx_arp <= 1'b1;
            else if(internal_valid_rx && (rx_arp_counter == 4'd4) && !(higher_bytes_rx == 16'h0800))
                error_rx_arp <= 1'b1;   
            else if(internal_valid_rx && (rx_arp_counter == 4'd5) && !(higher_bytes_rx == 16'h0001))
                error_rx_arp <= 1'b1;
            else if(internal_valid_rx && (rx_arp_counter == 4'd9) && !(lower_bytes_rx == SRC_IP[31:16]))
                error_rx_arp <= 1'b1;   
            else if(internal_valid_rx && (rx_arp_counter == 4'd10) && !(higher_bytes_rx == SRC_IP[15:0]))
                error_rx_arp <= 1'b1;
            else if(rx_arp_started)
            //else if(rx_arp_started || rx_arp_started_reg)
                error_rx_arp <= 1'b0;
                     
        end
    end
    
    assign lower_bytes_rx = internal_data_rx[15:0];
    assign higher_bytes_rx = internal_data_rx[31:16];
    
    always @(posedge clk) begin
        if(reset)
            rx_arp_counter_dl <= 1'b0;
         else
            rx_arp_counter_dl <= rx_arp_counter;
    end
    
    always @(posedge clk) begin
        if(reset)
        //if(reset || error_rx_arp)
            reply_arp_requested <= 1'b0;
        //else if(streaming_started && !arp_active)
            //reply_arp_requested <= 1'b0;
        else if((rx_arp_counter == 4'b0) && (rx_arp_counter_dl == 4'd10) && !error_rx_arp)
            reply_arp_requested <= 1'b1;
        else if((reply_arp_counter == 4'd12) && internal_ready_reply)
            reply_arp_requested <= 1'b0;
    end
    
    always @(posedge clk) begin
        if(reset)
            arp_active <= 1'b0;
        //else if((rx_arp_counter == 4'b0) || (error_rx_arp && (rx_arp_counter == 4'd8))) //10
        else if((rx_arp_counter == 4'b0) || (error_rx_arp)) // && (rx_arp_counter == 4'd8))) //10
            arp_active <= 1'b0;
        else if(internal_valid_rx && (rx_arp_counter == 4'd3) && (higher_bytes_rx == 16'h0806))
            arp_active <= 1'b1;
    end
    
    assign arp = arp_active;
    
    always @(posedge clk) begin
        if(reset)
            reply_arp_requested_dl <= 1'b0;
        else
            reply_arp_requested_dl <= reply_arp_requested;
    end
    
     /*************************************** ARP End ****************************************************/
     
     /*************************************** UDP ****************************************************/
     
     always @(posedge clk) begin
        if(reset)
        //if(reset || error_rx_udp)
            rx_udp_started_reg <= 1'b0;
        else if(rx_udp_started)
            rx_udp_started_reg <= 1'b1;
        else if((rx_udp_counter == rx_udp_total_length_shifted) && internal_valid_rx && internal_ready_rx)
            rx_udp_started_reg <= 1'b0;
        else if(error_rx_udp)
            rx_udp_started_reg <= 1'b0;
    end
    
    assign rx_udp_started = internal_valid_rx && internal_ready_rx && ((internal_data_rx == 32'hffffffff) || (internal_data_rx == SRC_MAC[47:16])) && (rx_udp_counter == 4'd0);
     
     always @(posedge clk) begin
        //if(reset || error_rx_udp)
        if(reset)
            rx_udp_counter <= 1'b0;
        else if (internal_valid_rx && internal_ready_rx && (rx_udp_started || rx_udp_started_reg) && (rx_udp_counter < rx_udp_total_length_shifted))
            rx_udp_counter <= rx_udp_counter + 1'b1;
        else if (((rx_udp_counter == rx_udp_total_length_shifted) && internal_valid_rx && internal_ready_rx) || error_rx_udp)
            rx_udp_counter <= 1'b0;
            
     end
     
     always @(posedge clk) begin
        if(reset)
            error_rx_udp <= 1'b0;
        else begin
            if((rx_udp_counter == rx_udp_total_length_shifted))
                error_rx_udp <= 1'b0;
            else if((rx_udp_counter == 0) && !((internal_data_rx == 32'hffffffff) || (internal_data_rx == SRC_MAC[47:16])) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if((rx_udp_counter == 1) && !((higher_bytes_rx == 16'hffff) || (higher_bytes_rx == SRC_MAC[15:0])) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if((rx_udp_counter == 3) && !(higher_bytes_rx == 16'h0800) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if((rx_udp_counter == 5) && !(lower_bytes_rx[7:0] == 8'h11) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if((rx_udp_counter == 7) && !(lower_bytes_rx == SRC_IP[31:16]) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if((rx_udp_counter == 8) && !(higher_bytes_rx == SRC_IP[15:0]) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if((rx_udp_counter == 9) && !(higher_bytes_rx == SRC_PORT) && internal_valid_rx && internal_ready_rx)
                error_rx_udp <= 1'b1;
            else if(rx_udp_started)
                error_rx_udp <= 1'b0;
        end
     end
    
     assign internal_ready_rx = (rx_udp_counter >= 11) && (rx_udp_counter <= rx_udp_total_length_shifted) ? rx_streaming_ready : 1'b1;
     assign rx_streaming_valid = (rx_udp_counter >= 11) && (rx_udp_counter <= rx_udp_total_length_shifted) ? internal_valid_rx : 1'b0;
     assign rx_streaming_data = (rx_udp_counter >= 11) && (rx_udp_counter <= rx_udp_total_length_shifted) ? internal_data_rx : 1'b0;
     assign rx_streaming_last = internal_valid_rx && internal_ready_rx && (rx_udp_counter == rx_udp_total_length_shifted);
     
     
     always @(posedge clk) begin
        if(reset) begin
            rx_udp_length <= 1'b0;
            rx_udp_packet_size <= 1'b0;
            rx_udp_total_length_shifted <= 8'd10;
        end
        else begin
            if((rx_udp_counter == 9) && !error_rx_udp && internal_valid_rx && internal_ready_rx) begin
                rx_udp_length <= lower_bytes_rx;
                rx_udp_total_length_shifted <= ((16'd30 + lower_bytes_rx) >> 2) > 16'd10 ? (16'd30 + lower_bytes_rx) >> 2 : 16'd10;
            end
            rx_udp_packet_size <= rx_udp_length - 16'd10;
            //rx_udp_total_length_shifted <= ((16'd40 + rx_udp_packet_size) >> 2) > 16'd10 ? (16'd40 + rx_udp_packet_size) >> 2 : 16'd10;
        end 
     end
     
     /*************************************** UDP End ****************************************************/
    
    always @(posedge clk) begin
       if (reset) begin
          header_checksum_temp1 <= 0;
          header_checksum_temp2 <= 0;
          header_checksum <= 0;
       end
       else begin
          header_checksum_temp1     <= 16'h4500 + MAC_LENGTH[15:0] +  16'h0000 + 16'h4000 + 16'hff11 + SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0];
          header_checksum_temp2     <= header_checksum_temp1[31:16] + header_checksum_temp1 [15:0];
          header_checksum           <= ~(header_checksum_temp2[31:16] + header_checksum_temp2 [15:0]);  
        end
    end
    
    always @(posedge clk) begin
        if(reset) begin
            udp_total_length_divided <= 1'b0;
            tx_packet_length <= 1'b0;
        end
        else begin
            udp_total_length_divided <= (tx_packet_length >> 2);
            tx_packet_length <= 16'd40 + PACKET_SIZE; //52
        end
    end
     
   
   /*************************************** Common ****************************************************/
    
    always @(posedge clk) begin
        if(reset) begin
            reply_arp_counter <= 1'b0;
            reply_tx_data <= 1'b0;
            reply_tx_valid <= 1'b0;
            reply_tx_last <= 1'b0;
            
            tx_udp_counter <= 1'b0;
        end
        else begin
            //if(internal_ready_reply && reply_arp_requested && (reply_arp_counter < 4'd10)) begin //arp
            if(internal_ready_reply && reply_arp_requested && (reply_arp_counter < 4'd10) && (tx_udp_counter == 0)) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                case(reply_arp_counter)
                    0 : reply_tx_data <= dest_mac_arp[47:16];
                    1 : reply_tx_data <= {dest_mac_arp[15:0], SRC_MAC[47:32]};
                    2 : reply_tx_data <= SRC_MAC[31:0];
                    3 : reply_tx_data <= 32'h08060001;
                    4 : reply_tx_data <= 32'h08000604;
                    5 : reply_tx_data <= {16'h0002, SRC_MAC[47:32]};
                    6 : reply_tx_data <= SRC_MAC[31:0];
                    7 : reply_tx_data <= SRC_IP;
                    8 : reply_tx_data <= dest_mac_arp[47:16];
                    9 : reply_tx_data <= {dest_mac_arp[15:0], dest_ip_arp[31:16]};
                    10 : reply_tx_data <= {dest_ip_arp[15:0], 16'h0000};
                    default: reply_tx_data <= 1'b0;
                endcase
            end
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd10) && (tx_udp_counter == 0)) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_data <= {dest_ip_arp[15:0], 16'h0000};
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
            end
            else if(reply_arp_requested && (reply_arp_counter == 4'd11) && (tx_udp_counter == 0)) begin //arp internal_ready_reply && 
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_data <= {32'h0000};
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
            else if(reply_arp_requested && (reply_arp_counter == 4'd12) && (tx_udp_counter == 0)) begin //arp internal_ready_reply && 
                reply_arp_counter <= 1'b0;
                reply_tx_data <= {32'h0000};
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
            
            //udp
            else if((tx_udp_counter < 16'd11) && internal_ready_reply && stream_valid_internal && streaming_started && (reply_arp_counter == 0)) begin // && !arp_active) begin
                tx_udp_counter <= tx_udp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                case(tx_udp_counter)
                    0 : reply_tx_data <= DST_MAC[47:16]; //dst mac
                    1 : reply_tx_data <= {DST_MAC[15:0], SRC_MAC[47:32]}; //dst mac + src mac
                    2 : reply_tx_data <= SRC_MAC[31:0]; //src mac
                    3 : reply_tx_data <= 32'h08004500; //
                    4 : reply_tx_data <= {MAC_LENGTH, 16'h0000};
                    5 : reply_tx_data <= 32'h4000FF11;
                    6 : reply_tx_data <= {header_checksum[15:0], SRC_IP[31:16]};
                    7 : reply_tx_data <= {SRC_IP[15:0], DST_IP[31:16]};
                    8 : reply_tx_data <= {DST_IP[15:0], SRC_PORT};
                    //8 : reply_tx_data <= {DST_IP[15:0], 16'h0000};
                    9 : reply_tx_data <= {DST_PORT, UDP_LENGTH}; // seq number raw [31:16]
                    //9 : reply_tx_data <= {SRC_PORT, DST_PORT}; // seq number raw [31:16]
                    10: reply_tx_data  <= 32'h00000000;
                    //10: reply_tx_data  <= {UDP_LENGTH, 16'h0000};
                    default: reply_tx_data <= 1'b0;
                endcase
            end
            else if((tx_udp_counter > 16'd10) && (tx_udp_counter < udp_total_length_divided) && internal_ready_reply && stream_valid_internal && stream_ready_internal && streaming_started && !full_reply && (reply_arp_counter == 0)) begin // && !arp_active
                tx_udp_counter <= tx_udp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                reply_tx_data <= stream_data_internal;
            end
            else if((tx_udp_counter == udp_total_length_divided) && internal_ready_reply && stream_valid_internal && stream_ready_internal && streaming_started && !full_reply && (reply_arp_counter == 0)) begin //udp // && !arp_active 
                tx_udp_counter <= 16'b0;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
                reply_tx_data  <= stream_data_internal;
            end
            
            else begin
                reply_tx_data <= 1'b0;
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
        end
    end
            
            

  reg ready_dl;
  always @(posedge clk)
    ready_dl <= internal_ready_reply;

  QueueLastGbemac2048 reply_fifo(
    .clock(clk),
    .reset(reset),
    .io_full(full_reply),
    .io_deq_ready(master_ready),
    .io_deq_valid(master_valid),
    .io_deq_bits(master_data),
    .io_enq_ready(internal_ready_reply),
    .io_enq_valid(internal_valid_reply),
    .io_enq_bits(internal_data_reply),
    .io_enq_last(internal_last_reply),
    .io_deq_last(master_last)
  );
  
  assign internal_data_reply = reply_tx_data;
  assign internal_valid_reply = reply_tx_valid;
  assign internal_last_reply = reply_tx_last;

  wire full8192;
  //QueueLastGbemac8192 fifo_32b(
  QueueLastGbemac2048 fifo_32b(
    .clock(clk),
    .reset(reset),
    .io_full(full8192),
    .io_deq_ready(stream_ready_internal),
    .io_deq_valid(stream_valid_internal),
    .io_deq_bits(stream_data_internal),
    .io_enq_ready(tx_streaming_ready_internal),
    .io_enq_valid(tx_streaming_valid && tx_streaming_ready),
    .io_enq_bits(tx_streaming_data),
    .io_enq_last(tx_streaming_last),
    .io_deq_last(stream_last_internal)
  );

  always @(posedge clk) begin
    if(reset)
        streaming_started <= 1'b0;
    else if(tx_streaming_valid && tx_streaming_ready) // && !arp_active)
        streaming_started <= 1'b1;
  end
  
  //assign tx_streaming_ready = tx_streaming_ready_internal;
  assign tx_streaming_ready = tx_streaming_ready_internal && (!odd_package_arrived || !even_package_arrived);
  
  //assign stream_ready_internal = (tx_udp_counter > 16'd10) && internal_ready_reply && stream_valid_internal && streaming_started && !full_reply; // && !arp_active 
  assign stream_ready_internal = (tx_udp_counter > 16'd10) && internal_ready_reply && stream_valid_internal && streaming_started && !full_reply && ((odd_package_arrived && first_package_out) || (even_package_arrived && !first_package_out)); // && !arp_active 
    
  always @(posedge clk) begin
    if(reset) begin
        counter_in1 <= 1'b0;
        counter_in2 <= 1'b0;
        counter_in_out <= 1'b0;
    end
    else begin
        if(!odd_package_arrived && tx_streaming_valid && tx_streaming_ready && (counter_in1 < ((packetSize >> 2) - 1)))
            counter_in1 <= counter_in1 + 1'b1;
        else if(!odd_package_arrived && tx_streaming_valid && tx_streaming_ready && (counter_in1 == ((packetSize >> 2) - 1)))
            counter_in1 <= 1'b0;
        if(!even_package_arrived && tx_streaming_valid && tx_streaming_ready && (counter_in2 < ((packetSize >> 2) - 1)))
            counter_in2 <= counter_in2 + 1'b1;
        else if(!even_package_arrived && tx_streaming_valid && tx_streaming_ready && (counter_in2 == ((packetSize >> 2) - 1)))
            counter_in2 <= 1'b0;
        if((counter_in_out < ((packetSize >> 2) - 1)) && stream_ready_internal && stream_valid_internal)
            counter_in_out <= counter_in_out + 1'b1;
        else if((counter_in_out == ((packetSize >> 2) - 1)) && stream_ready_internal && stream_valid_internal)
            counter_in_out <= 1'b0;
    end
  end
  
  always @(posedge clk) begin
    if(reset) begin
        odd_package_arrived <= 1'b0;
        even_package_arrived <= 1'b0;
        first_package_out <= 1'b1;
    end
    else begin
        if((counter_in1 == ((packetSize >> 2) - 1)) && tx_streaming_valid && tx_streaming_ready)
            odd_package_arrived <= 1'b1;
        else if((counter_in_out == ((packetSize >> 2) - 1)) && stream_ready_internal && stream_valid_internal && first_package_out)
            odd_package_arrived <= 1'b0;
        if((counter_in2 == ((packetSize >> 2) - 1)) && tx_streaming_valid && tx_streaming_ready)
            even_package_arrived <= 1'b1;
        else if((counter_in_out == ((packetSize >> 2) - 1)) && stream_ready_internal && stream_valid_internal && !first_package_out)
            even_package_arrived <= 1'b0;
        if((counter_in_out == ((packetSize >> 2) - 1)) && stream_ready_internal && stream_valid_internal)
            first_package_out <= !first_package_out;
    end
  end



/*ila_0 my_ila0(
	.clk(clk), // input wire clk


	.probe0(reply_tx_data), // input wire [31:0]  probe0  
	.probe1(reply_tx_valid), // input wire [0:0]  probe1 
	.probe2(reply_tx_last), // input wire [0:0]  probe2 
	.probe3(internal_ready_reply), // input wire [0:0]  probe3 
	.probe4(streaming_started), // input wire [0:0]  probe4 
	.probe5(reply_arp_requested), // input wire [0:0]  probe5 
	.probe6(reply_arp_counter), // input wire [3:0]  probe6 
	.probe7(rx_arp_counter), // input wire [15:0]  probe7
	.probe8(rx_arp_started_reg)
);*/


/*ila_1 my_ila1(
	.clk(clk), // input wire clk


	.probe0(internal_data_rx), // input wire [31:0]  probe0  
	.probe1(internal_valid_rx), // input wire [0:0]  probe1 
	.probe2(internal_last_rx), // input wire [0:0]  probe2 
	.probe3(internal_ready_rx), // input wire [0:0]  probe3 
	.probe4(error_rx_udp), // input wire [0:0]  probe4 
	.probe5(rx_streaming_valid), // input wire [0:0]  probe5 
	.probe6(rx_streaming_data), // input wire [31:0]  probe6 
	.probe7(rx_udp_counter), // input wire [15:0]  probe7
	.probe8(rx_udp_started_reg), // input wire [0:0]  probe8
	.probe9(reply_tx_data), // input wire [31:0]  probe9
	.probe10(reply_tx_valid), // input wire [0:0]  probe10 
	.probe11(reply_tx_last), // input wire [0:0]  probe11 
	.probe12(internal_ready_reply), // input wire [0:0]  probe12
	.probe13(reply_arp_counter), // input wire [3:0]  probe13 
	.probe14(rx_arp_counter), // input wire [3:0]  probe14
	.probe15(reply_arp_requested), // input wire [0:0]  probe15
	.probe16(rx_arp_started_reg), // input wire [0:0]  probe16
	.probe17(tx_udp_counter) // input wire [15:0]  probe17
);*/

  
endmodule

