`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2020 03:37:54 PM
// Design Name: 
// Module Name: sseg_test
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


module sseg_top(
    input clk,
    input [15:0] sw,
    output [6:0] seg,
    output [3:0] an
    );
    
    wire [6:0] seg0, seg1, seg2, seg3;
    
    sseg s0(.hex(sw[3:0]), .seg(seg0));     
    sseg s1(.hex(sw[7:4]), .seg(seg1));     
    sseg s2(.hex(sw[11:8]), .seg(seg2));     
    sseg s3(.hex(sw[15:12]), .seg(seg3));     

    sseg_mux display(.clk(clk), .rst(1'b0), .dig0(seg0), .dig1(seg1), .dig2(seg2), .dig3(seg3), .an(an), .sseg(seg));
endmodule