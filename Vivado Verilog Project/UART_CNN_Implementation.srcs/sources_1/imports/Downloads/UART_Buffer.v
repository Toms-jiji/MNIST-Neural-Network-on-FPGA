`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2024 12:11:56 PM
// Design Name: 
// Module Name: UART_Buffer
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


module UART_Buffer(
    input wire data_ready,          // signal when new data word is complete (received)
    input wire [7:0] data_in,     // data to FIFO
    input wire clk,
    input wire reset,
    
//    output reg [120:0] temp,
    output reg image_ready,
    output reg data_rdy,
//    output integer count,
    output reg [12543:0] image  //12543  //128
    );
    
//    reg data_rdy;
//    reg [120:0] temp;
//    reg [12543:0] image;
    integer count=0;
    always@(negedge clk)begin
        if(reset==1)begin
            image<=0;
            count<=0;
            image_ready<=0;
            data_rdy<=0;
        end
        else begin
            if(count==1568)begin  //1568 //16
                count<=0;
                image_ready<=1;
            end
            else if(data_ready==1)begin
                   data_rdy<=~data_rdy;
//                   temp<= (image<<8);
//                   image <= data_in;
//                   out <= {0{32-image_size-count},image,0{count}}
                   image <= (image) | (data_in << (8*count));
                   count<=count+1;
            end
        end
    end
        
//    always @(negedge clk)begin
//        if(data_ready==1)begin
//            data_rdy<=1;
//        end
//    end
    
endmodule
