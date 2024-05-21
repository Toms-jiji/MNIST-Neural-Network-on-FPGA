`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2024 12:48:46
// Design Name: 
// Module Name: uart_receiver
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

module uart_receiver
    #(
        parameter   DBITS = 7,          // number of data bits in a data word
                    SB_TICK = 16        // number of stop bit / oversampling ticks (1 stop bit)
    )
    (
        input clk_100MHz,               
        input reset,                    
        input rx,                       
        input sample_tick,              // sample tick from baud rate generator
        output reg data_ready_out,          // signal when new data word is complete (received)
        output reg [15:0] data_out     // data to FIFO
    );
    
    // State Machine States
    localparam [1:0] idle  = 2'b00,
                     start = 2'b01,
                     data  = 2'b10,
                     stop  = 2'b11;
    
    // Registers                 
    reg [1:0] state, next_state;        
    reg [3:0] tick_reg, tick_next;      
    reg [2:0] nbits_reg, nbits_next;    
    reg [7:0] data_reg;
    reg [7:0] data_next; 
    reg byte_num=0;  
    reg data_ready;
    
    // Register Logic
    always @(posedge clk_100MHz, posedge reset)
        if(reset) begin
            state <= idle;
            tick_reg <= 0;
            nbits_reg <= 0;
            data_reg <= 0;
        end
        else begin
            state <= next_state;
            tick_reg <= tick_next;
            nbits_reg <= nbits_next;
            data_reg <= data_next;
        end        

    // State Machine Logic
    always @* begin
        next_state = state;
        data_ready = 1'b0;
        tick_next = tick_reg;
        nbits_next = nbits_reg;
        data_next = data_reg;
        
        case(state)
            idle:
                if(~rx) begin               // when data line goes LOW (start condition)
                    next_state = start;
                    tick_next = 0;
                end
            start:
                if(sample_tick)
                    if(tick_reg == 7) begin
                        next_state = data;
                        tick_next = 0;
                        nbits_next = 0;
                    end
                    else
                        tick_next = tick_reg + 1;
            data:
                if(sample_tick)
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = {rx, data_reg[7:1]};
                        if(nbits_reg == 7)
                            next_state = stop;
                        else
                            nbits_next = nbits_reg + 1;
                    end
                    else
                        tick_next = tick_reg + 1;
            stop:
                if(sample_tick)begin
                    if(tick_reg == (7)) begin
                        if(byte_num==0)begin
                            byte_num =1;
                            data_out =(data_reg<<8);
                        end
                        else begin
                            byte_num =0;
                            data_out = data_out|data_reg;
                            data_ready = 1'b1;
                        end
                            
                        next_state = idle;
                        
                    end
                    else
                        tick_next = tick_reg + 1;
                end
        endcase                    
    end
    
    
    always@(negedge clk_100MHz)begin
        if(data_ready==1)
            data_ready_out = 1'b1;
        else
            data_ready_out = 1'b0;
            
    end
endmodule
