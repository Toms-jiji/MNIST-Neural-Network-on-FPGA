`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2024 10:40:30 AM
// Design Name: 
// Module Name: Top_UART
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


module Top_UART(
    input wire clk,
    input wire reset,
    input wire RX,
    output wire [12543:0] image,
    output wire image_ready,
    output wire TX  // fpga is transmitting on this pin
    );
    
//    wire [12543:0] image; //remove later
//    wire image_ready;
    wire [7:0] data_for_TX;
    wire TX_start;
   
    wire tick;
     wire data_ready;
     wire [7:0] data_out;
     wire tx_done;
     //wire [12543:0] image;
     wire [120:0] temp;
     wire data_rdy;
     wire img_rdy;
     wire shift_data_flag;
     wire [7:0] image_buf;
   
    
    reg bg_reset=0;
    baud_rate_generator#(.N(10),.M(651))
    BG1( 
        
      .clk_100MHz(clk),       // basys 3 clock
      .reset(reset),            // reset
      .tick(tick)             // sample tick
    );
    
    uart_receiver#(.DBITS(8), .SB_TICK(16))
    UR1(   
        .clk_100MHz(clk),               
        .reset(reset),                    
        .rx(RX),                       
        .sample_tick(tick),              // sample tick from baud rate generator
        .data_ready(data_ready),          // signal when new data word is complete (received)
        .data_out(data_out)     // data to FIFO
    );
    
    UART_Buffer UB1(
        .data_ready(data_ready),          // signal when new data word is complete (received)
        .data_in(data_out),     // data to FIFO
        .clk(clk),
        .reset(reset),
        .image_ready(image_ready),
        .image(image),
        .data_rdy(data_rdy)
//        .temp(temp)
    );
    
    Parallel_to_serial PS1(
        .image(image),
        .image_ready(image_ready),
        .clk(clk),
        .reset(reset),
        .next_data(tx_done),
    
        .TX_start(TX_start),
        .serial_data(data_for_TX)
        
//        .img_rdy(img_rdy),//remove
//        .shift_data_flag(shift_data_flag),//remove
//        .image_buf(image_buf)  //remove
    );
    
    uart_transmitter#(.DBITS(8),.SB_TICK(16))
    UT1(   
        .clk_100MHz(clk),               // basys 3 FPGA
        .reset(reset),                    // reset
        .tx_start(TX_start),                 // begin data transmission (FIFO NOT empty)
        .sample_tick(tick),              // from baud rate generator
        .data_in(data_for_TX),      // data word from FIFO
        .tx_done(tx_done),             // end of transmission
        .tx(TX)                       // transmitter data line
    );
endmodule
