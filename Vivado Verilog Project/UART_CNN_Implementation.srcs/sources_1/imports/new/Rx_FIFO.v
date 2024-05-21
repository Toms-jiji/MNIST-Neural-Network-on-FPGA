`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2024 18:06:37
// Design Name: 
// Module Name: Rx_FIFO
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


module Rx_FIFO #(parameter pixel_count = 784) (
    input clock,
    input reset,
    input [15:0] rx_data,
    input rx_ready,
    output [(pixel_count*16)-1:0] out_data,
    output reg out_data_ready
    );

    reg [9:0] count;
    reg [(pixel_count*16)-1:0] out_data_fifo;

    always @(posedge clock) begin
        if(reset) begin
            out_data_fifo <= 0;
            count <= 0;

        end
        else begin
            if(rx_ready) begin
                count <= count + 1;
                if(count < (pixel_count)) begin
                    out_data_fifo[16*(count)+:16] <= rx_data;
                end
                else begin
                    out_data_fifo <= out_data_fifo;
                end
            end
            else begin
                out_data_fifo <= out_data_fifo;
            end
        end
    end

    always@(posedge clock) begin
        if(reset) begin
            out_data_ready <= 1'b0;
        end
        else begin
            if(count==pixel_count)
                out_data_ready <= 1'b1;
            else if(count== (pixel_count+26)) begin
                out_data_ready <= 1'b0;
                //count <= 0;
            end
            else
                out_data_ready <= out_data_ready;
        end
    end

    assign out_data = (out_data_ready)?out_data_fifo:0;
endmodule
