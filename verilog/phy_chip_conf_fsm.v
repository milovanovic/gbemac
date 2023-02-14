`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2022 01:50:51 PM
// Design Name: 
// Module Name: phy_chip_conf_fsm
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


module phy_chip_conf_fsm(
    input clk,
    input reset,
    
    output [15:0] ctrlData,
    output [4:0]  rgAd,
    output        writeCtrlData
    
    );
    
    localparam [1:0] 
        idleState = 4'b0000,
        resetState = 4'b0001, 
        setData1State = 4'b0010,
        sendData1State = 4'b0011,
        wait1State = 4'b0100,
        setData2State = 4'b0101,
        sendData2State = 4'b0110,
        wait2State = 4'b0111,
        setData3State = 4'b1000,
        sendData3State = 4'b1001,
        wait3State = 4'b1010;
        
    reg state_reg, state_next;
    reg [31:0] counter;
    reg [15:0] ctrlData_reg;
    reg [4:0]  rgAd_reg;
    reg writeCtrlData_reg;
    reg reset_reg;
    
    always @(posedge clk) begin
        if(reset) begin
            state_reg <= idleState;
        end
        else begin
            state_reg <= state_next;
        end
    end
    
    always @(state_reg, counter, reset, reset_reg)  begin
        state_next = state_reg;
        
        case(state_reg)
            idleState:
                if(!reset && reset_reg)
                    state_next <= resetState;
            resetState: 
                state_next <= setData1State;
            setData1State:
            begin
                ctrlData_reg <= 1'b0;
                //rgAd_reg <= 5'd9;
                rgAd_reg <= 5'd0;
                writeCtrlData_reg <= 16'h2100; //nexys video: 16'h0200, arty a7: 16'h2100
                state_next <= sendData1State;
            end
            sendData1State:
            begin
                ctrlData_reg <= 1'b1;
                state_next <= wait1State;
            end
            wait1State:
            begin
                if(counter == 32'd1000000)
                    //state_next <= setData2State;
                    state_next <= idleState;
            end
            setData2State:
            begin
                ctrlData_reg <= 1'b0;
                rgAd_reg <= 5'd4;
                writeCtrlData_reg <= 16'h0000;
                state_next <= sendData2State;
            end
            sendData2State:
            begin
                ctrlData_reg <= 1'b1;
                state_next <= wait2State;
            end
            wait2State:
            begin
                if(counter == 32'd1000000)
                    state_next <= setData3State;
            end
            setData3State:
            begin
                ctrlData_reg <= 1'b0;
                rgAd_reg <= 5'd0;
                writeCtrlData_reg <= 16'h9000;
                state_next <= sendData3State;
            end
            sendData3State:
            begin
                ctrlData_reg <= 1'b1;
                state_next <= wait3State;
            end
            wait3State:
            begin
                if(counter == 32'd1000000)
                    state_next <= idleState;
            end 
        endcase
    end
    
    always @(posedge clk) begin
        reset_reg <= reset;
    end
    
    always @(posedge clk) begin
        if(reset)
            counter <= 1'b0;
        else begin
            if((state_reg == wait1State) || (state_reg == wait2State) || (state_reg == wait3State))
                counter <= counter + 1'b1;
            else
                counter <= 1'b0;
        end
    end

    assign ctrlData = ctrlData_reg;
    assign rgAd = rgAd_reg;
    assign writeCtrlData = writeCtrlData_reg;
    
    
endmodule
