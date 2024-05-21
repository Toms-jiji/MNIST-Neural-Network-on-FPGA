`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2024 18:44:44
// Design Name: 
// Module Name: top_dnn_sim
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


module top_dnn_sim(

    );
    
    reg clock;
    reg reset;
    wire [3:0] out_data;
    wire valid_out;
    wire [0:6] seg;
    wire [3:0] digits; 
    wire UART_RX;
    reg mode;
    wire stickey;
    wire UART_TX;
    
    uart_tb UT(
    .r_Rx_Serial(UART_RX)
    );
    
    DNN_top DNN (
        .clock(clock),
        .reset(reset),
        .out_data(out_data),
        .mode(mode),
        .UART_RX(UART_RX),
        .UART_TX(UART_TX),
        .stickey(stickey),
        .valid_out(valid_out),
        .seg(seg),
        .digits(digits)
    );
    
    always #5 clock = ~clock;
    
    initial begin
    clock=0;
    reset=1;
    
    //UART_RX=1; // idle State
    
    #100 
    reset = 0;
    #50
    mode=0;
    end
    

endmodule

   //------------UART TB -----------------------------------
   
   module uart_tb (
output reg r_Rx_Serial
);
 
  // Testbench uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 1041;
  parameter c_BIT_PERIOD      = 104166;
   
  reg r_Clock = 0;
  reg r_Tx_DV = 0;
  wire w_Tx_Done;
  reg [7:0] r_Tx_Byte = 0;
//  r_Rx_Serial = 1;z
  wire [7:0] w_Rx_Byte;
  integer pixels=0;
 
  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
       
      // Send Start Bit
      r_Rx_Serial <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          r_Rx_Serial <= i_Data[ii];
          #(c_BIT_PERIOD);
        end
       
      // Send Stop Bit
      r_Rx_Serial <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE
    
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
  // Main Testing:
  initial
    begin
      // Send a command to the UART (exercise Rx)
      //@(posedge r_Clock);
      
      for (pixels = 0; pixels < (2); pixels = pixels + 1) begin
          UART_WRITE_BYTE(8'hAA);
          UART_WRITE_BYTE(8'h55);
      end
//      UART_WRITE_BYTE(8'hAA);
//      UART_WRITE_BYTE(8'h55);
//      UART_WRITE_BYTE(8'hAA);
//      UART_WRITE_BYTE(8'h55);
//      UART_WRITE_BYTE(8'hAA);
//      UART_WRITE_BYTE(8'h55);
//      UART_WRITE_BYTE(8'hAA);
//      UART_WRITE_BYTE(8'h55);
      //@(posedge r_Clock);
    end 
endmodule