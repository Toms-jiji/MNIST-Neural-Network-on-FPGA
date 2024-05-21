`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2024 16:31:26
// Design Name: 
// Module Name: Image_memory
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

`include "D:/IISC/SEM_2/FPGA/CNN/Working_NN_05_04_2024_03_08_pm 1/Working_NN_05_04_2024_03_08_pm/Working_NN_05_04_2024_03_08_pm.srcs/sources_1/imports/Toms/include.v"
module Image_memory #(parameter numPixel = 3,addressWidth=10,dataWidth=16,imageFile="w_1_15.mif")
    ( 
    input clk,
    input wen,
    input ren,
    input [addressWidth-1:0] wadd,
    input [addressWidth-1:0] radd,
    input [dataWidth-1:0] win,
    output reg [dataWidth-1:0] wout);
    
    reg [dataWidth-1:0] mem [numPixel-1:0];

    `ifdef preinstalled
        initial
		begin
	        $readmemb(imageFile, mem);
	    end
	`else
		always @(posedge clk)
		begin
			if (wen)
			begin
				mem[wadd] <= win;
			end
		end 
    `endif
    
    always @(posedge clk)
    begin
        if (ren)
        begin
            wout <= mem[radd];
        end
    end 
endmodule
