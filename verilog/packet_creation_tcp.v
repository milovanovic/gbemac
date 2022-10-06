`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2022 03:48:03 PM
// Design Name: 
// Module Name: rx_protocols
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

module packet_creation_tcp (
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
    
    input start_tcp,
    input fin_gen,
    
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
    
    reg start_tcp_reg;
    
    reg [31:0] ack_num_tcp, seq_num_tcp, ack_num_tcp_next, seq_num_tcp_next;
    
    reg [47:0] dest_mac_tcp;
    reg [31:0] dest_ip_tcp;
    
    reg [15:0] tx_tcp_counter;
    reg [15:0] tx_tcp_counter_dl;
    reg [15:0] rx_tcp_counter;
    reg [15:0] rx_tcp_counter_dl;
    
    reg error_rx_tcp_ack, error_rx_tcp_data, error_rx_tcp_fin;
    
    reg tcp_syn_tx_done, tcp_syn_ack_rx_done, tcp_ack_tx_done, tcp_data_tx_done, tcp_ack_data_rx_done, tcp_fin_tx_done, tcp_ack_fin_rx_done, tcp_fin_rx_done, tcp_ack_fin_tx_done;
    reg tcp_syn_tx_done_dl, tcp_syn_ack_rx_done_dl, tcp_ack_tx_done_dl, tcp_ack_data_rx_done_dl, tcp_fin_rx_done_dl, tcp_ack_fin_rx_done_dl, tcp_ack_fin_tx_done_dl, tcp_fin_tx_done_dl, tcp_data_tx_done_dl;
    
    reg [15:0] header_checksum;
    
    reg [15:0] dst_port;
    
    reg [63:0] tx_tcp_header_checksum_tmp, tx_tcp_header_checksum_tmp0;
    reg [31:0] tx_tcp_header_checksum, tx_tcp_header_checksum_tmp1, tx_tcp_header_checksum_tmp2;
    reg [31:0] tx_ipv4_header_checksum, tx_ipv4_header_checksum_tmp1, tx_ipv4_header_checksum_tmp2;
    reg [15:0] tcp_payload_length, tcp_total_length, tcp_total_length_divided, tx_packet_length;
    
    reg tcp_fin_flag, tcp_ack_flag, tcp_seq_flag;
    
    reg tcp_started;
    
    reg [15:0] tcp_identification;
    
    reg [7:0] data_tx_pause_counter;
    reg data_tx_pause_done;
    reg [15:0] packet_num_counter;
    
    reg [15:0] tx_data_packet_size;
    reg [63:0] payload_sum_a, payload_sum_b;
    reg use_sum_a;
    
    wire stream_valid_internal;
    wire stream_ready_internal;
    wire [31:0] stream_data_internal;
    wire stream_last_internal;
    
    reg [15:0] streaming_data_counter, streaming_data_counter_out;
    
    wire tx_streaming_ready_internal;
    wire correct_data_group;
    reg data_streaming_started, data_streaming_started_dl;
    wire fifo_32b_overflow, fifo_32b_underflow;
    
    reg [3:0] tcp_ack_data_rx_counter;
    
    reg stream_out_ready_reg, stream_out_valid_reg;
    
    reg help_indicator, use_sum_a_dl;
    reg [1:0] use_sum_counter;
    
    reg a_done, b_done;
    reg full_reg;
    
    reg fin_gen_reg;
    reg fin_gen_eop, fin_gen_eop_dl;
    reg [15:0] fin_data_counter;
    wire streaming_input_valid, streaming_input_ready, streaming_input_last;
    wire [31:0] streaming_input_data;
  
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
    
    assign internal_ready_rx = 1'b1;
    
    always @(posedge clk) begin
        if(reset) begin
            SRC_MAC <= 1'b0;
            SRC_IP <= 1'b0;
            SRC_PORT <= 1'b0;
            DST_MAC <= 1'b0;
            DST_IP <= 1'b0;
            DST_PORT <= 1'b0;
            PACKET_SIZE <= 1'b0;
        end
        else begin
            SRC_MAC <= srcMac;
            SRC_IP <= srcIp;
            SRC_PORT <= srcPort;
            DST_MAC <= dstMac;
            DST_IP <= dstIp;
            DST_PORT <= dstPort;
            PACKET_SIZE <= packetSize;
        end
    end
    
    /*************************************** ARP ****************************************************/
    
    always @(posedge clk) begin
        if(reset)
            rx_arp_started_reg <= 1'b0;
        else if(rx_arp_started)
            rx_arp_started_reg <= 1'b1;
        else if((rx_arp_counter == 4'd12) && internal_valid_rx)
            rx_arp_started_reg <= 1'b0;
        else if(error_rx_arp)
            rx_arp_started_reg <= 1'b0;
    end
    
    assign rx_arp_started = internal_valid_rx && ((internal_data_rx == 32'hffffffff) || (internal_data_rx == SRC_MAC[47:16]));
    
    always @(posedge clk) begin
        if(reset) begin
            rx_arp_counter <= 1'b0;
            dest_mac_arp <= 1'b0;
            dest_ip_arp <= 1'b0;
            error_rx_arp <= 1'b0;
        end
        else begin
            if (internal_valid_rx && (rx_arp_started || rx_arp_started_reg) && (rx_arp_counter < 4'd12))
                rx_arp_counter <= rx_arp_counter + 1'b1;
            else if (((rx_arp_counter == 4'd12) && internal_valid_rx) || error_rx_arp || internal_last_rx)
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
            reply_arp_requested <= 1'b0;
        else if((rx_arp_counter == 4'b0) && (rx_arp_counter_dl == 4'd12) && !error_rx_arp)
            reply_arp_requested <= 1'b1;
        else if((reply_arp_counter == 4'd12) && internal_ready_reply)
            reply_arp_requested <= 1'b0;
    end
    
    always @(posedge clk) begin
        if(reset)
            arp_active <= 1'b0;
        else if((rx_arp_counter == 4'b0) || (error_rx_arp && (rx_arp_counter == 4'd8))) //10
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
    
    
    
    /*************************************** TCP ****************************************************/

    always @(posedge clk) begin
        if(reset || error_rx_tcp_ack)
            start_tcp_reg <= 1'b0;
        else if(start_tcp)
            start_tcp_reg <= 1'b1;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_started <= 1'b0;
        else if(start_tcp && !start_tcp_reg)
            tcp_started <= 1'b1;
        else if(tcp_ack_fin_tx_done) //rx
            tcp_started <= 1'b0;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_syn_ack_rx_done_dl <= 1'b0;
        else
            tcp_syn_ack_rx_done_dl <= tcp_syn_ack_rx_done;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_ack_tx_done_dl <= 1'b0;
        else
            tcp_ack_tx_done_dl <= tcp_ack_tx_done;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_data_tx_done_dl <= 1'b0;
        else
            tcp_data_tx_done_dl <= tcp_data_tx_done;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_ack_data_rx_done_dl <= 1'b0;
        else
            tcp_ack_data_rx_done_dl <= tcp_ack_data_rx_done;
    end
  
    always @(posedge clk) begin
        if(reset)
            tcp_ack_fin_rx_done_dl <= 1'b0;
        else
            tcp_ack_fin_rx_done_dl <= tcp_ack_fin_rx_done;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_fin_rx_done_dl <= 1'b0;
        else
            tcp_fin_rx_done_dl <= tcp_fin_rx_done;
    end
    
    always @(posedge clk) begin
        if(reset)
            ack_num_tcp_next <= 1'b0;
        else if(error_rx_tcp_ack)
            ack_num_tcp_next <= 1'b0;
        else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && !tcp_syn_ack_rx_done_dl)
            ack_num_tcp_next <= ack_num_tcp + 1'b1;
        else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_ack_data_rx_done && tcp_fin_rx_done && !tcp_fin_rx_done_dl && tcp_fin_flag)
            ack_num_tcp_next <= ack_num_tcp + 1'b1; 
    end
    
    always @(posedge clk) begin
        if(reset)
            seq_num_tcp_next <= 1'b0;
        else
            seq_num_tcp_next <= seq_num_tcp + 1'b1;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_payload_length <= 1'b0;
        else
            tcp_payload_length <= tcp_total_length - 16'd50;
    end
    
    always @(posedge clk) begin
        if(reset) begin
            tcp_total_length_divided <= 1'b0;
            tx_packet_length <= 1'b0;
            tx_data_packet_size <= 1'b0;
        end
        else begin
            tcp_total_length_divided <= (tx_packet_length >> 2);
            tx_packet_length <= 16'd52 + PACKET_SIZE;
            tx_data_packet_size <= 16'd40 + PACKET_SIZE + 2; // 2 for byte allignment
        end
    end
    
    always @(posedge clk) begin
        if(reset)
            rx_tcp_counter_dl <= 1'b0;
        else
            rx_tcp_counter_dl <= rx_tcp_counter;
    end
    
    always @(posedge clk) begin
        if(reset)
            tx_tcp_counter_dl <= 1'b0;
        else
            tx_tcp_counter_dl <= tx_tcp_counter;
    end
    
    always @(posedge clk) begin
        if(reset)
            tcp_identification <= 16'h998E;//1'b0;
        else if((tcp_syn_ack_rx_done && !tcp_syn_ack_rx_done_dl) || (tcp_ack_tx_done && !tcp_ack_tx_done_dl) || (tcp_data_tx_done && !tcp_data_tx_done_dl) || (tcp_fin_rx_done_dl && !tcp_fin_rx_done_dl))
            tcp_identification <= tcp_identification + 1'b1;
    end
    
    always @(posedge clk) begin
        if(reset) begin
            data_tx_pause_counter <= 1'b0;
            data_tx_pause_done <= 1'b0;
        end
        else begin
            if((data_tx_pause_counter == 8'b0) && !tcp_ack_tx_done_dl && tcp_ack_tx_done)
                data_tx_pause_counter <= data_tx_pause_counter + 1'b1;
            else if((data_tx_pause_counter > 8'b0) && (data_tx_pause_counter < 8'hFF))
                data_tx_pause_counter <= data_tx_pause_counter + 1'b1;
            if(data_tx_pause_counter == 8'hFF)
                data_tx_pause_done <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(reset) begin
            rx_tcp_counter <= 1'b0;
        end
        else begin
            if(error_rx_tcp_ack || error_rx_tcp_data || error_rx_tcp_fin || arp_active || (reply_arp_requested && !reply_arp_requested_dl) || (!arp_active && fin_gen_reg && fin_gen_eop && !fin_gen_eop_dl))
                rx_tcp_counter <= 1'b0;
            //ack syn    
            else if (internal_valid_rx && start_tcp_reg && tcp_syn_tx_done && !tcp_syn_ack_rx_done && (rx_tcp_counter < 5'd16)) // && !error_rx_arp)    13
                rx_tcp_counter <= rx_tcp_counter + 1'b1;
            else if ((rx_tcp_counter == 5'd16) && start_tcp_reg && tcp_syn_tx_done && !tcp_syn_ack_rx_done && internal_valid_rx)
                rx_tcp_counter <= 1'b0;
            // data ack
            else if(internal_valid_rx && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && !tcp_ack_data_rx_done && (rx_tcp_counter < 5'd13))
                rx_tcp_counter <= rx_tcp_counter + 1'b1;
            else if ((rx_tcp_counter == 5'd13) && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && !tcp_ack_data_rx_done && internal_valid_rx)
                rx_tcp_counter <= 1'b0;
            // fin ack
            else if (internal_valid_rx && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_fin_tx_done && !tcp_ack_fin_rx_done && (rx_tcp_counter < 5'd13))
                rx_tcp_counter <= rx_tcp_counter + 1'b1;
            else if ((rx_tcp_counter == 5'd13) && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_fin_tx_done && !tcp_ack_fin_rx_done && internal_valid_rx)
                rx_tcp_counter <= 1'b0;
           // fin     
           else if (internal_valid_rx && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_rx_done && (rx_tcp_counter < 5'd13))
                rx_tcp_counter <= rx_tcp_counter + 1'b1;
            else if ((rx_tcp_counter == 5'd13) && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_rx_done && internal_valid_rx)
                rx_tcp_counter <= 1'b0;
        end
    end

    // flags
    always @(posedge clk) begin
        if(reset) begin
            tcp_syn_tx_done <= 1'b0;
            tcp_syn_ack_rx_done <= 1'b0;
            tcp_ack_tx_done <= 1'b0;
            tcp_data_tx_done <= 1'b0;
            tcp_ack_data_rx_done <= 1'b0;
            tcp_fin_tx_done <= 1'b0;
            tcp_ack_fin_rx_done <= 1'b0;
            tcp_fin_rx_done <= 1'b0;
            tcp_ack_fin_tx_done <= 1'b0;
        end
        else begin
            if(error_rx_tcp_ack) begin
                tcp_syn_ack_rx_done <= 1'b0;
                tcp_ack_tx_done <= 1'b0;
                tcp_data_tx_done <= 1'b0;
                tcp_ack_data_rx_done <= 1'b0;
                tcp_fin_tx_done <= 1'b0;
                tcp_ack_fin_rx_done <= 1'b0;
                tcp_fin_rx_done <= 1'b0;
                tcp_ack_fin_tx_done <= 1'b0;
            end
            else if(start_tcp_reg && !tcp_syn_tx_done && (tx_tcp_counter == 8'd16) && internal_valid_reply && internal_ready_reply)
                tcp_syn_tx_done <= 1'b1;
            else if((rx_tcp_counter == 5'd16) && start_tcp_reg && tcp_syn_tx_done && !tcp_syn_ack_rx_done && internal_valid_rx)
                tcp_syn_ack_rx_done <= 1'b1;
            else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && !tcp_ack_tx_done && (tx_tcp_counter == 8'd13) && internal_valid_reply && internal_ready_reply)
                tcp_ack_tx_done <= 1'b1;
            else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && !tcp_data_tx_done && (tx_tcp_counter == tcp_total_length_divided) && internal_valid_reply && internal_ready_reply)   
                tcp_data_tx_done <= 1'b1;    
            else if((tcp_ack_data_rx_counter == 4'd5) && (correct_data_group || fin_gen_reg))
                tcp_ack_data_rx_done <= 1'b1;
            else if((rx_tcp_counter == 5'd13) && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && tcp_fin_tx_done && !tcp_ack_fin_rx_done && !tcp_fin_rx_done && internal_valid_rx) begin
                tcp_ack_fin_rx_done <= 1'b1;
                if(tcp_fin_flag)
                    tcp_fin_rx_done <= 1'b1;
            end
            else if((rx_tcp_counter == 5'd13) && start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_rx_done && internal_valid_rx) begin
                if(tcp_fin_flag)
                    tcp_fin_rx_done <= 1'b1;
            end
            else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && tcp_fin_rx_done && !tcp_ack_fin_tx_done && (tx_tcp_counter == 8'd13) && internal_valid_reply && internal_ready_reply && tcp_fin_flag)
                tcp_ack_fin_tx_done <= 1'b1;
            else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_tx_done && (tx_tcp_counter == 8'd13) && internal_valid_reply && internal_ready_reply)
                tcp_fin_tx_done <= 1'b1;
            else if(tcp_ack_data_rx_done && !fin_gen_reg) begin
                tcp_data_tx_done <= 1'b0;
                tcp_ack_data_rx_done <= 1'b0;
            end
                   
        end
    end
   
    // ack, seq, packet_size, fin flag
    always @(posedge clk) begin
        if(reset) begin
            tcp_total_length <= 1'b0;
            ack_num_tcp <= 1'b0;
            seq_num_tcp <= 1'b0;    
            tcp_seq_flag <= 1'b0;
            tcp_ack_flag <= 1'b0;
            tcp_fin_flag <= 1'b0;
        end
        else if(error_rx_tcp_ack) begin
            ack_num_tcp <= 1'b0;
            seq_num_tcp <= 1'b0;
            if(error_rx_tcp_data || error_rx_tcp_fin) begin
                tcp_total_length <= 1'b0;
                tcp_seq_flag <= 1'b0;
                tcp_ack_flag <= 1'b0;
                tcp_fin_flag <= 1'b0;
            end
        end
        else if(!(rx_tcp_counter_dl == 16'd8) && (rx_tcp_counter == 16'd8)) begin
            tcp_seq_flag <= 1'b0;
            tcp_ack_flag <= 1'b0;
            tcp_fin_flag <= 1'b0;
        end
        else if((rx_tcp_counter == 16'd9) && internal_valid_rx && internal_ready_rx && start_tcp_reg && tcp_syn_tx_done) begin
            ack_num_tcp[31:16] <= internal_data_rx[15:0]; // NOTE: ack and seq places are switched in tx and rx transactions
        end
        else if((rx_tcp_counter == 16'd10) && internal_valid_rx && internal_ready_rx && start_tcp_reg && tcp_syn_tx_done) begin
            ack_num_tcp[15:0] <= internal_data_rx[31:16];
            if(!tcp_ack_tx_done || tcp_fin_tx_done)
                seq_num_tcp[31:16] <= internal_data_rx[15:0];
        end
        else if((rx_tcp_counter == 16'd11) && internal_valid_rx && internal_ready_rx && start_tcp_reg && tcp_syn_tx_done) begin
            tcp_seq_flag <= internal_data_rx[1];
            tcp_ack_flag <= internal_data_rx[4];
            tcp_fin_flag <= internal_data_rx[0];

            if(!tcp_ack_tx_done || tcp_fin_tx_done)
                seq_num_tcp[15:0] <= internal_data_rx[31:16];
            
        end
        else if((rx_tcp_counter == 16'd4) && internal_valid_rx && internal_ready_rx && start_tcp_reg && tcp_syn_tx_done)
            tcp_total_length <= internal_data_rx[31:16] + 16'd10; // 14-4
            
        if(tcp_ack_tx_done && tcp_ack_data_rx_done && !tcp_ack_data_rx_done_dl && !error_rx_tcp_ack && !reset)
            seq_num_tcp <= seq_num_tcp + PACKET_SIZE + 2;
    end
   
    //error
    always @(posedge clk) begin
        if(reset || (!(rx_tcp_counter_dl == 1'b0) && (rx_tcp_counter == 1'b0)) || (!internal_valid_rx && internal_ready_rx)) begin
            error_rx_tcp_ack <= 1'b0;
            error_rx_tcp_data <= 1'b0;
            error_rx_tcp_fin <= 1'b0;
        end
        else begin
            if(start_tcp_reg && tcp_syn_tx_done && !tcp_syn_ack_rx_done) begin
                if((rx_tcp_counter == 16'd0) && internal_valid_rx && internal_ready_rx && !(internal_data_rx == SRC_MAC[47:16]))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd1) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == SRC_MAC[15:0]))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd3) && internal_valid_rx && internal_ready_rx && !(internal_data_rx == 32'h08004500))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd5) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[7:0] == 8'h06))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd7) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[15:0] == SRC_IP[31:16]))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd8) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == SRC_IP[15:0]))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd9) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == SRC_PORT))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd10) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[15:0] == seq_num_tcp_next[31:16]))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd11) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == seq_num_tcp_next[15:0]))
                    error_rx_tcp_ack <= 1'b1;
                else if((rx_tcp_counter == 16'd11) && internal_valid_rx && internal_ready_rx && !((internal_data_rx[4] == 1'b1) && (internal_data_rx[1] == 1'b1)))
                    error_rx_tcp_ack <= 1'b1;
            end
            else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_rx_done) begin
                if((rx_tcp_counter == 16'd0) && internal_valid_rx && internal_ready_rx && !(internal_data_rx == SRC_MAC[47:16]))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd1) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == SRC_MAC[15:0]))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd3) && internal_valid_rx && internal_ready_rx && !(internal_data_rx == 32'h08004500))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd5) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[7:0] == 8'h06))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd7) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[15:0] == SRC_IP[31:16]))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd8) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == SRC_IP[15:0]))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd9) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[31:16] == SRC_PORT))
                    error_rx_tcp_fin <= 1'b1;
                else if((rx_tcp_counter == 16'd11) && internal_valid_rx && internal_ready_rx && !(internal_data_rx[0] == 1'b1))
                    error_rx_tcp_fin <= 1'b1;
            end
        end
    end
    
    
    always @(posedge clk) begin
       if (reset) begin
          tx_ipv4_header_checksum_tmp1 <= 0;
          tx_ipv4_header_checksum_tmp2 <= 0;
          tx_ipv4_header_checksum <= 0;
       end
       else begin
          if(!tcp_syn_tx_done)
             tx_ipv4_header_checksum_tmp1     <= 16'h4500 + 16'h0034 +  tcp_identification + 16'h4000 + 16'h8006 + SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0];
          else if(tcp_syn_tx_done && !tcp_ack_tx_done)
             tx_ipv4_header_checksum_tmp1     <= 16'h4500 + 16'h0028 +  tcp_identification + 16'h4000 + 16'h8006 + SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0];
          else if(tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done)
             tx_ipv4_header_checksum_tmp1     <= 16'h4500 + 16'h0028 + PACKET_SIZE + 2 + tcp_identification + 16'h4000 + 16'h8006 + SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0];
          else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && !tcp_fin_tx_done)
             tx_ipv4_header_checksum_tmp1     <= 16'h4500 + 16'h0028 +  tcp_identification + 16'h4000 + 16'h8006 + SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0];
          else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_fin_tx_done && !tcp_ack_fin_tx_done)
             tx_ipv4_header_checksum_tmp1     <= 16'h4500 + 16'h0028 +  tcp_identification + 16'h4000 + 16'h8006 + SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0];
          
          tx_ipv4_header_checksum_tmp2     <= tx_ipv4_header_checksum_tmp1[31:16] + tx_ipv4_header_checksum_tmp1[15:0];
          tx_ipv4_header_checksum           <= ~(tx_ipv4_header_checksum_tmp2[31:16] + tx_ipv4_header_checksum_tmp2[15:0]);  
        end
     end
     
     //checksum for tcp
     always @(posedge clk) begin
       if (reset) begin
          tx_tcp_header_checksum_tmp <= 0;
          tx_tcp_header_checksum_tmp0 <= 0;
          tx_tcp_header_checksum_tmp1 <= 0;
          tx_tcp_header_checksum_tmp2 <= 0;
          tx_tcp_header_checksum <= 0;
       end
       else begin
          if(!tcp_syn_tx_done) begin
              tx_tcp_header_checksum_tmp     <= SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0] + 16'h0006 + 16'h0020 + SRC_PORT + DST_PORT + seq_num_tcp[31:16] + seq_num_tcp[15:0] + 16'h0000 + 16'h0000 + 16'h8002 + 16'hFAF0 + 16'h0000 + 16'h0204 + 16'h05B4 + 16'h0103 + 16'h0308 + 16'h0101 + 16'h0402;
          end
          else if(tcp_syn_tx_done && !tcp_ack_tx_done) begin
              tx_tcp_header_checksum_tmp     <= SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0] + 16'h0006 + 16'h0014 + SRC_PORT + DST_PORT + seq_num_tcp[31:16] + seq_num_tcp[15:0] + ack_num_tcp_next[31:16] + ack_num_tcp_next[15:0] + 16'h5010 + 16'h2014 + 16'h0000;
          end
          else if(tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done) begin
              if((!use_sum_a && correct_data_group) || (use_sum_a && !correct_data_group)) begin
                  tx_tcp_header_checksum_tmp     <= SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0] + 16'h0006 + 16'h0014 + 2 + PACKET_SIZE + SRC_PORT + DST_PORT + seq_num_tcp[31:16] + seq_num_tcp[15:0] + ack_num_tcp_next[31:16] + ack_num_tcp_next[15:0] + 16'h5018 + 16'h2014 + 16'h0000 + payload_sum_a;
              end
              else if((use_sum_a && correct_data_group) || (!use_sum_a && !correct_data_group)) begin
                  tx_tcp_header_checksum_tmp     <= SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0] + 16'h0006 + 16'h0014 + 2 + PACKET_SIZE + SRC_PORT + DST_PORT + seq_num_tcp[31:16] + seq_num_tcp[15:0] + ack_num_tcp_next[31:16] + ack_num_tcp_next[15:0] + 16'h5018 + 16'h2014 + 16'h0000 + payload_sum_b;
              end  
          end
          else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_fin_rx_done && !tcp_ack_fin_tx_done) begin
              tx_tcp_header_checksum_tmp     <= SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0] + 16'h0006 + 16'h0014 + SRC_PORT + DST_PORT + seq_num_tcp[31:16] + seq_num_tcp[15:0] + ack_num_tcp_next[31:16] + ack_num_tcp_next[15:0] + 16'h5010 + 16'h2014 + 16'h0000;
          end
          else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && !tcp_fin_tx_done) begin
              tx_tcp_header_checksum_tmp     <= SRC_IP[31:16] + SRC_IP[15:0] + DST_IP[31:16] + DST_IP[15:0] + 16'h0006 + 16'h0014 + SRC_PORT + DST_PORT + seq_num_tcp[31:16] + seq_num_tcp[15:0] + ack_num_tcp_next[31:16] + ack_num_tcp_next[15:0] + 16'h5011 + 16'h2014 + 16'h0000;
          end
          
          tx_tcp_header_checksum_tmp0 <= tx_tcp_header_checksum_tmp[63:32] + tx_tcp_header_checksum_tmp[31:0];
          tx_tcp_header_checksum_tmp1 <= tx_tcp_header_checksum_tmp0[63:32] + tx_tcp_header_checksum_tmp0[31:0];
          tx_tcp_header_checksum_tmp2     <= tx_tcp_header_checksum_tmp1[31:16] + tx_tcp_header_checksum_tmp1[15:0];
          tx_tcp_header_checksum           <= ~(tx_tcp_header_checksum_tmp2[31:16] + tx_tcp_header_checksum_tmp2[15:0]);  
        end
     end
    

   /*************************************** TCP End ****************************************************/
    
   
   /*************************************** Common ****************************************************/
    
    always @(posedge clk) begin
        if(reset) begin
            reply_arp_counter <= 1'b0;
            reply_tx_data <= 1'b0;
            reply_tx_valid <= 1'b0;
            reply_tx_last <= 1'b0;
            
            tx_tcp_counter <= 1'b0;
        end
        else begin
            if(internal_ready_reply && reply_arp_requested && (reply_arp_counter < 4'd10) && !tcp_ack_tx_done) begin //arp
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
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd10)) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_data <= {dest_ip_arp[15:0], 16'h0000};
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
            end
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd11)) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_data <= {32'h0000};
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd12)) begin //arp
                reply_arp_counter <= 1'b0;
                reply_tx_data <= {32'h0000};
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
            
            // seq
            else if(tcp_started && !tcp_syn_tx_done && (tx_tcp_counter < 8'd16) && internal_ready_reply) begin
                tx_tcp_counter <= tx_tcp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                case(tx_tcp_counter)
                    0 : reply_tx_data <= DST_MAC[47:16]; //dst mac
                    1 : reply_tx_data <= {DST_MAC[15:0], SRC_MAC[47:32]}; //dst mac + src mac
                    2 : reply_tx_data <= SRC_MAC[31:0]; //src mac
                    3 : reply_tx_data <= 32'h08004500; //
                    4 : reply_tx_data <= {16'h0034, tcp_identification};
                    5 : reply_tx_data <= 32'h40008006;
                    6 : reply_tx_data <= {tx_ipv4_header_checksum[15:0], SRC_IP[31:16]};
                    7 : reply_tx_data <= {SRC_IP[15:0], DST_IP[31:16]};
                    8 : reply_tx_data <= {DST_IP[15:0], SRC_PORT};
                    9 : reply_tx_data <= {DST_PORT, seq_num_tcp[31:16]}; // seq number raw [31:16]
                    10 : reply_tx_data  <= {seq_num_tcp[15:0], 16'h0000}; // seq number raw [15:0] ack num[31:16]
                    11: reply_tx_data  <= {16'h0000, 16'h8002}; //ack num[15:0] offset, flags - syn set
                    12: reply_tx_data  <= {16'hFAF0, tx_tcp_header_checksum[15:0]}; // window, checksum
                    13: reply_tx_data  <= 32'h00000204;
                    14: reply_tx_data  <= 32'h05B40103;
                    15: reply_tx_data  <= 32'h03080101;
                    16: reply_tx_data  <= 32'h04020000;
                    default: reply_tx_data <= 1'b0;
                endcase
            end
            else if(tcp_started && !tcp_syn_tx_done && (tx_tcp_counter == 8'd16) && internal_ready_reply) begin //tcp
                tx_tcp_counter <= 8'b0;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
                reply_tx_data  <= 32'h04020000;
            end
            // ack
            else if(tcp_syn_ack_rx_done && tcp_syn_tx_done && !tcp_ack_tx_done && (tx_tcp_counter < 8'd13) && internal_ready_reply) begin //tcp
                tx_tcp_counter <= tx_tcp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                case(tx_tcp_counter)
                    0 : reply_tx_data <= DST_MAC[47:16]; //dst mac
                    1 : reply_tx_data <= {DST_MAC[15:0], SRC_MAC[47:32]}; //dst mac + src mac
                    2 : reply_tx_data <= SRC_MAC[31:0]; //src mac
                    3 : reply_tx_data <= 32'h08004500; //
                    4 : reply_tx_data <= {16'h0028, tcp_identification};
                    5 : reply_tx_data <= 32'h40008006;
                    6 : reply_tx_data <= {tx_ipv4_header_checksum[15:0], SRC_IP[31:16]};
                    7 : reply_tx_data <= {SRC_IP[15:0], DST_IP[31:16]};
                    8 : reply_tx_data <= {DST_IP[15:0], SRC_PORT};
                    9 : reply_tx_data <= {DST_PORT, seq_num_tcp[31:16]}; // seq number raw [31:16]
                    10 : reply_tx_data  <= {seq_num_tcp[15:0], ack_num_tcp_next[31:16]}; // seq number raw [15:0] ack num[31:16]
                    11: reply_tx_data  <= {ack_num_tcp_next[15:0], 16'h5010}; //ack num[15:0] offset, flags - ack set
                    12: reply_tx_data  <= {16'h2014, tx_tcp_header_checksum[15:0]}; // window, checksum
                    13: reply_tx_data  <= 32'h00000000;
                    default: reply_tx_data <= 1'b0;
                endcase
            end
            else if(tcp_syn_tx_done && !tcp_ack_tx_done && (tx_tcp_counter == 8'd13) && internal_ready_reply) begin //tcp
                tx_tcp_counter <= 8'b0;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
                reply_tx_data  <= 32'h00000000;
            end
            // data
            else if(!fin_gen_reg || (fin_gen_reg && (!(fin_gen_eop || reply_tx_last) && !tcp_data_tx_done))) begin
                if(tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done && (tx_tcp_counter < 16'd14) && internal_ready_reply && data_tx_pause_done && data_streaming_started) begin
                    tx_tcp_counter <= tx_tcp_counter + 1'b1;
                    reply_tx_valid <= 1'b1;
                    reply_tx_last <= 1'b0;
                    case(tx_tcp_counter)
                        0 : reply_tx_data <= DST_MAC[47:16]; //dst mac
                        1 : reply_tx_data <= {DST_MAC[15:0], SRC_MAC[47:32]}; //dst mac + src mac
                        2 : reply_tx_data <= SRC_MAC[31:0]; //src mac
                        3 : reply_tx_data <= 32'h08004500; //
                        4 : reply_tx_data <= {tx_data_packet_size, tcp_identification};
                        5 : reply_tx_data <= 32'h40008006;
                        6 : reply_tx_data <= {tx_ipv4_header_checksum[15:0], SRC_IP[31:16]};
                        7 : reply_tx_data <= {SRC_IP[15:0], DST_IP[31:16]};
                        8 : reply_tx_data <= {DST_IP[15:0], SRC_PORT};
                        9 : reply_tx_data <= {DST_PORT, seq_num_tcp[31:16]}; // seq number raw [31:16]
                        10 : reply_tx_data  <= {seq_num_tcp[15:0], ack_num_tcp_next[31:16]}; // seq number raw [15:0] ack num[31:16]
                        11: reply_tx_data  <= {ack_num_tcp_next[15:0], 16'h5018}; //ack num[15:0] offset, flags - ack set //5010
                        12: reply_tx_data  <= {16'h2014, tx_tcp_header_checksum[15:0]}; // window, checksum
                        13: reply_tx_data  <= 32'h00000000;
                        default: reply_tx_data <= 1'b0;
                    endcase
                end
                else if(tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done && (tx_tcp_counter > 16'd13) && (tx_tcp_counter < tcp_total_length_divided) && stream_ready_internal && data_tx_pause_done && stream_valid_internal && !full_reply) begin
                    tx_tcp_counter <= tx_tcp_counter + 1'b1;
                    reply_tx_valid <= 1'b1;
                    reply_tx_last <= 1'b0;
                    reply_tx_data <= stream_data_internal;
                end
                else if(tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done && (tx_tcp_counter == tcp_total_length_divided) && stream_ready_internal && stream_valid_internal && !full_reply) begin //tcp
                    tx_tcp_counter <= 8'b0;
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
            
            
            // arp
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter < 4'd10) && tcp_data_tx_done && tcp_ack_data_rx_done && fin_gen_reg) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                tx_tcp_counter <= 1'b0;
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
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd10) && tcp_data_tx_done && tcp_ack_data_rx_done && fin_gen_reg) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_data <= {dest_ip_arp[15:0], 16'h0000};
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
                tx_tcp_counter <= 1'b0;
            end
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd11) && tcp_data_tx_done && tcp_ack_data_rx_done && fin_gen_reg) begin //arp
                reply_arp_counter <= reply_arp_counter + 1'b1;
                reply_tx_data <= {32'h0000};
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
            else if(internal_ready_reply && reply_arp_requested && (reply_arp_counter == 4'd12) && tcp_data_tx_done && tcp_ack_data_rx_done && fin_gen_reg) begin //arp
                reply_arp_counter <= 1'b0;
                reply_tx_data <= {32'h0000};
                reply_tx_valid <= 1'b0;
                reply_tx_last <= 1'b0;
            end
            
            // fin ack
            else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && tcp_fin_rx_done && !tcp_ack_fin_tx_done && (tx_tcp_counter < 8'd13) && internal_ready_reply) begin
                tx_tcp_counter <= tx_tcp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                case(tx_tcp_counter)
                    0 : reply_tx_data <= DST_MAC[47:16]; //dst mac
                    1 : reply_tx_data <= {DST_MAC[15:0], SRC_MAC[47:32]}; //dst mac + src mac
                    2 : reply_tx_data <= SRC_MAC[31:0]; //src mac
                    3 : reply_tx_data <= 32'h08004500; //
                    4 : reply_tx_data <= {16'h0028, tcp_identification};
                    5 : reply_tx_data <= 32'h40008006;
                    6 : reply_tx_data <= {tx_ipv4_header_checksum[15:0], SRC_IP[31:16]};
                    7 : reply_tx_data <= {SRC_IP[15:0], DST_IP[31:16]};
                    8 : reply_tx_data <= {DST_IP[15:0], SRC_PORT};
                    9 : reply_tx_data <= {DST_PORT, seq_num_tcp[31:16]}; // seq number raw [31:16]
                    10 : reply_tx_data  <= {seq_num_tcp[15:0], ack_num_tcp_next[31:16]}; // seq number raw [15:0] ack num[31:16]
                    11: reply_tx_data  <= {ack_num_tcp_next[15:0], 16'h5010}; //ack num[15:0] offset, flags - ack set //5011 5010
                    12: reply_tx_data  <= {16'h2014, tx_tcp_header_checksum[15:0]}; // window, checksum
                    13: reply_tx_data  <= 32'h00000000;
                    default: reply_tx_data <= 1'b0;
                endcase
            end
            else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && tcp_fin_rx_done && !tcp_ack_fin_tx_done && (tx_tcp_counter == 8'd13) && internal_ready_reply) begin
                tx_tcp_counter <= 8'b0;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
                reply_tx_data  <= 32'h00000000;
            end
            // fin
            else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_tx_done && (tx_tcp_counter < 8'd13) && internal_ready_reply && fin_gen_reg) begin //tcp
           
                tx_tcp_counter <= tx_tcp_counter + 1'b1;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b0;
                case(tx_tcp_counter)
                    0 : reply_tx_data <= DST_MAC[47:16]; //dst mac
                    1 : reply_tx_data <= {DST_MAC[15:0], SRC_MAC[47:32]}; //dst mac + src mac
                    2 : reply_tx_data <= SRC_MAC[31:0]; //src mac
                    3 : reply_tx_data <= 32'h08004500; //
                    4 : reply_tx_data <= {16'h0028, tcp_identification};
                    5 : reply_tx_data <= 32'h40008006;
                    6 : reply_tx_data <= {tx_ipv4_header_checksum[15:0], SRC_IP[31:16]};
                    7 : reply_tx_data <= {SRC_IP[15:0], DST_IP[31:16]};
                    8 : reply_tx_data <= {DST_IP[15:0], SRC_PORT};
                    9 : reply_tx_data <= {DST_PORT, seq_num_tcp[31:16]}; // seq number raw [31:16]
                    10 : reply_tx_data  <= {seq_num_tcp[15:0], ack_num_tcp_next[31:16]}; // seq number raw [15:0] ack num[31:16]
                    11: reply_tx_data  <= {ack_num_tcp_next[15:0], 16'h5011}; //ack num[15:0] offset, flags - ack set //5011 5010
                    12: reply_tx_data  <= {16'h2014, tx_tcp_header_checksum[15:0]}; // window, checksum
                    13: reply_tx_data  <= 32'h00000000;
                    default: reply_tx_data <= 1'b0;
                endcase
            end
            else if(tcp_syn_tx_done && tcp_ack_tx_done && tcp_data_tx_done && tcp_ack_data_rx_done && !tcp_fin_tx_done && (tx_tcp_counter == 8'd13) && internal_ready_reply) begin //tcp
                tx_tcp_counter <= 8'b0;
                reply_tx_valid <= 1'b1;
                reply_tx_last <= 1'b1;
                reply_tx_data  <= 32'h00000000;
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
    QueueLastGbemac8192 fifo_32b(
    .clock(clk),
    .reset(reset),
    .io_full(full8192),
    .io_deq_ready(stream_ready_internal),
    .io_deq_valid(stream_valid_internal),
    .io_deq_bits(stream_data_internal),
    .io_enq_ready(tx_streaming_ready_internal),
    .io_enq_valid(streaming_input_valid),
    .io_enq_bits(streaming_input_data),
    .io_enq_last(streaming_input_last),
    .io_deq_last(stream_last_internal)
  );

  assign tx_streaming_ready = tx_streaming_ready_internal && (correct_data_group || tcp_data_tx_done) && !(a_done && b_done);

  assign correct_data_group = (use_sum_a && (!data_streaming_started || (data_streaming_started && (streaming_data_counter_out >= (PACKET_SIZE >> 2)) && (streaming_data_counter_out < (PACKET_SIZE >> 1))))) || (!use_sum_a && (streaming_data_counter_out < (PACKET_SIZE >> 2)));
  

  assign stream_ready_internal = tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done && (tx_tcp_counter > 16'd13) && (tx_tcp_counter <= tcp_total_length_divided) && internal_ready_reply && data_tx_pause_done && stream_valid_internal && !full_reply && (a_done || b_done); //&& (!full_reply || !full_reg)
  
  always @(posedge clk) begin
    if(reset) begin
        payload_sum_a <= 1'b0;
        payload_sum_b <= 1'b0;
    end
    else begin
        if(tx_streaming_valid && tx_streaming_ready) begin
            if(use_sum_a)
                payload_sum_a <= payload_sum_a + tx_streaming_data;
            else if(!use_sum_a)
                payload_sum_b <= payload_sum_b + tx_streaming_data;
        end

        if(correct_data_group && tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done && (tx_tcp_counter == 16'd13)) begin
            if(!use_sum_a)
                payload_sum_a <= 1'b0;
            else if(use_sum_a)
                payload_sum_b <= 1'b0;
        end
        else if(!correct_data_group && tcp_syn_tx_done && tcp_ack_tx_done && !tcp_data_tx_done && use_sum_a && (tx_tcp_counter == 16'd13))
            payload_sum_a <= 1'b0;
    end
  end
  
  always @(posedge clk) begin
    if(reset)
        streaming_data_counter <= 1'b0;
    else
        if(tx_streaming_valid && tx_streaming_ready && (streaming_data_counter < ((PACKET_SIZE >> 1) - 1)))
            streaming_data_counter <= streaming_data_counter + 1'b1;
        else if(tx_streaming_valid && tx_streaming_ready && (streaming_data_counter == ((PACKET_SIZE >> 1) - 1)))
            streaming_data_counter <= 1'b0;
  end
  
  always @(posedge clk) begin
    if(reset)
        streaming_data_counter_out <= 1'b0;
    else
        if(stream_valid_internal && stream_ready_internal && (streaming_data_counter_out < ((PACKET_SIZE >> 1) - 1)))
            streaming_data_counter_out <= streaming_data_counter_out + 1'b1;
        else if(stream_valid_internal && stream_ready_internal && (streaming_data_counter_out == ((PACKET_SIZE >> 1) - 1)))
            streaming_data_counter_out <= 1'b0;
  end
  
  always @(posedge clk) begin
    if(reset)
        use_sum_a <= 1'b1;
    else if((streaming_data_counter == ((PACKET_SIZE >> 2) - 1)) && tx_streaming_valid && tx_streaming_ready)
        use_sum_a <= 1'b0;
    else if((streaming_data_counter == ((PACKET_SIZE >> 1) - 1)) && tx_streaming_valid && tx_streaming_ready)
        use_sum_a <= 1'b1;
  end
  
  always @(posedge clk) begin
    if(reset)
        data_streaming_started <= 1'b0;
    else if(use_sum_a && (streaming_data_counter == ((PACKET_SIZE >> 2) - 1)) && tx_streaming_valid && tx_streaming_ready)
        data_streaming_started <= 1'b1;
  end
  
  always @(posedge clk) begin
    if(reset)
        data_streaming_started_dl <= 1'b0;
    else
        data_streaming_started_dl <= data_streaming_started;
  end
  
  always @(posedge clk) begin
     if(reset)   
        tcp_ack_data_rx_counter <= 1'b0;
     else if(start_tcp_reg && tcp_syn_tx_done && tcp_syn_ack_rx_done && tcp_ack_tx_done && tcp_data_tx_done && !tcp_ack_data_rx_done)
        tcp_ack_data_rx_counter <= tcp_ack_data_rx_counter + 1'b1;
     else if(tcp_ack_data_rx_done)
        tcp_ack_data_rx_counter <= 1'b0;
  end
  
  always @(posedge clk) begin
    if(reset) begin
       stream_out_ready_reg <= 1'b0;
       stream_out_valid_reg <= 1'b0; 
    end
    else begin
        if(stream_valid_internal)
             stream_out_valid_reg <= 1'b1;
        if(stream_ready_internal)
             stream_out_ready_reg <= 1'b1; 
    end
  end
  
  always @(posedge clk) begin
    if(reset)
        help_indicator <= 1'b0;
    else if(!use_sum_a && data_streaming_started && (use_sum_counter == 1'b1))
        help_indicator <= 1'b1;
    else if((use_sum_counter == 2'b10))
        help_indicator <= 1'b0;
  end
  
  always @(posedge clk) begin
    if(reset)
        use_sum_a_dl <= 1'b1;
    else
        use_sum_a_dl <= use_sum_a;
  end
  
  always @(posedge clk) begin
    if(reset)
        use_sum_counter <= 1'b0;
    else if(!use_sum_a && use_sum_a_dl && (use_sum_counter == 1'b0))
        use_sum_counter <= 1'b1;
    else if(!use_sum_a && use_sum_a_dl && (use_sum_counter == 1'b1) && data_streaming_started)
        use_sum_counter <= 2'b10;
  end
  
  always @(posedge clk) begin
    if(reset) begin
        a_done <= 1'b0;
        b_done <= 1'b0;
    end
    else begin
        if((streaming_data_counter == ((PACKET_SIZE >> 1) - 1)) && tx_streaming_valid && tx_streaming_ready)
            b_done <= 1'b1;
        else if(stream_valid_internal && stream_ready_internal && (streaming_data_counter_out == ((PACKET_SIZE >> 1) - 1)))
            b_done <= 1'b0;
        if((streaming_data_counter == ((PACKET_SIZE >> 2) - 1)) && tx_streaming_valid && tx_streaming_ready)
            a_done <= 1'b1;
        else if(stream_valid_internal && stream_ready_internal && (streaming_data_counter_out == ((PACKET_SIZE >> 2) - 1)))
            a_done <= 1'b0;
    end
  end
  
  always @(posedge clk) begin
    if(reset)
        full_reg <= 1'b0;
    else
        full_reg <= full_reply;
  end
    
    always @(posedge clk) begin
        if(reset) begin
            fin_gen_reg <= 1'b0;
            fin_gen_eop <= 1'b0;
            fin_gen_eop_dl <= 1'b0;
        end
        else begin
            if(fin_gen)
                fin_gen_reg <= 1'b1;
            if((fin_gen_reg || fin_gen) && (reply_tx_last || tcp_data_tx_done))
                fin_gen_eop <= 1'b1;
            fin_gen_eop_dl <= fin_gen_eop;
        end    
    end
    
    assign streaming_input_valid = fin_gen_reg ? !fin_gen_eop : tx_streaming_valid && tx_streaming_ready;
    assign streaming_input_data = fin_gen_reg ? 1'b0 : tx_streaming_data;
    assign streaming_input_last = tx_streaming_last;
  
   
endmodule

