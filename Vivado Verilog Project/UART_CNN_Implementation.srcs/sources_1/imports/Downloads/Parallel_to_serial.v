`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2024 12:52:07 PM
// Design Name: 
// Module Name: Parallel_to_serial
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


module Parallel_to_serial(
    input wire [12543:0] image,
    input wire image_ready,
    input wire clk,
    input wire reset,
    input wire next_data,
    
    output reg TX_start,
//    output reg img_rdy,//remove
//    output reg shift_data_flag,//remove
//    output reg [12543:0] image_buf,  //remove
    output reg [7:0] serial_data
    );
    
    reg img_rdy;//remove
     reg shift_data_flag;//remove
     reg [12543:0] image_buf;  //remove
    
//    reg [7:0] image_buf;  //12543  //128
//    reg shift_data_flag;
//    reg img_rdy;
    integer counter;
    
    
    always@(negedge clk)begin
        if(reset)begin
            serial_data<=0;
            counter<=0;
            image_buf<=0;
            shift_data_flag<=0;
            TX_start<=0;
            img_rdy<=0;
        end
        else begin
            img_rdy <=image_ready;
            
            if(next_data==1)begin
                TX_start<=0;
                if(counter==1568)               //16 1568
                    shift_data_flag<=0;
                else
                    shift_data_flag<=1;
            end
            else if(img_rdy==0 && image_ready==1)begin
                image_buf <=image;
                shift_data_flag<=1;
                end
            else if(shift_data_flag==1)begin
                    counter <= counter+1;
                    TX_start <=1;
                    serial_data <= image_buf[7:0];
                    image_buf <= image_buf>>8;
                    shift_data_flag<=0;
            end
        end
    end
    
    
//    always@(negedge clk)begin
//        if(next_data==1)begin
//            TX_start<=0;
//            if(counter==1)               //16 1568
//                shift_data_flag<=0;
//            else
//                shift_data_flag<=1;
//        end
//    end


//    always@(posedge image_ready)begin
//        if(image_ready==1)begin
//            img_rdy<=1;
//            shift_data_flag<=1;
//        end
//    end
endmodule
