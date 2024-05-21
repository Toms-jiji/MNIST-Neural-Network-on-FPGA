//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2024 15:35:33
// Design Name: 
// Module Name: DNN_top
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


module DNN_top(
    input clock,
    input reset,
    output [3:0] out_data,
    output reg valid_out,
    input UART_RX,
    output UART_TX,
    input mode,
    output stickey,
    output [0:6] seg,
    output [3:0] digits
    );
    
    wire [31:0] out_data_ann;
    wire out_valid;
    //reg valid_out;
    assign out_data = out_data_ann[3:0];
    
    reg weightValid;
    reg biasValid;
    reg [31:0] weightValue;
    reg [31:0] biasValue;
    reg [31:0] config_layer_num;
    reg [31:0] config_neuron_num;
    reg [16-1:0] expected;
    reg [(784*16)-1:0] in2;

    always @(posedge clock) begin
        if(reset) begin
            valid_out <= 1'b0;
        end
        else begin
            if(out_valid)
                valid_out <= 1'b1;
            else
                valid_out <= valid_out;
        end
    end
    
    always @(posedge clock) begin
        if(reset) begin
            weightValid <= 0;
            biasValid <= 0;
            weightValue <= 0;
            biasValue <= 0;
            config_layer_num <= 0;
            config_neuron_num <= 0;
        end
    end

    wire ren,wen;
    reg [9:0] radd;
    reg [9:0] radd1;
    reg [9:0] wadd;
    reg [15:0] win;
    wire [15:0] wout;
    wire [(784*16)-1:0] out_rx_fifo;


    // Read from memory after 4 clock cycle 
    reg [1:0] count;
    reg read_valid;
    reg in_valid;
    always @(posedge clock) begin
        if(reset) begin
            count<=0;
            read_valid <= 0;
        end
        else begin
            count=count+1;
            if(count==3) begin
                read_valid <= 1'b1;
            end
            else begin
                read_valid <= read_valid;
            end
        end
    end

    assign ren = read_valid;
    wire [15:0] wout_rd;
    assign wout_rd = (ren)?(wout):16'd0;

    always @(posedge clock) begin
        if(reset | out_valid) begin
            in2 <= 0;
            radd <=0;
            radd1 <= 0;
        end
        else begin
            if(ren) begin
                in2[16*(radd1)+:16] <= wout_rd;
                radd <= radd+1;
                radd1 <= radd;
            end
        end
    end

    always @(posedge clock) begin
        if(reset) begin
            in_valid <= 1'b0;
        end
        else begin
            if(radd==784) begin
                in_valid <= 1'b1;
            end
            else if(radd==800) begin
                in_valid <= 1'b0;
            end
            else begin
                in_valid <= in_valid;
            end
        end
    end

    //assign in_valid = (radd==784)?1'b1:1'b0; 

    Image_memory #(.numPixel(784),.addressWidth(10),.dataWidth(16),.imageFile("Input_image_01.mif"))
    IM (
        .clk(clock),
        .wen(wen),
        .ren(ren),
        .wadd(wadd),
        .radd(radd),
        .win(win),
        .wout(wout)
    );
//-----------------UART Receiver-----------------------------------------------------
    wire uart_rx_data_ready;
    
    Top_UART UART(
        .clk(clock),
        .reset(reset),
        .RX(UART_RX),
        .image(out_rx_fifo),
        .image_ready(uart_rx_data_ready),
        .TX(UART_TX)  // fpga is transmitting on this pin
    );
    
    reg [5:0] count_valid;
    reg valid_uart;
    reg flag;
    always @(posedge clock) begin
        if(reset) begin
            count_valid <= 0;
            flag <= 1'b0;
        end
        else begin
            if(uart_rx_data_ready && (!flag)) begin
                valid_uart <= 1'b1;
                count_valid <= count_valid +1;
                if(count_valid == 52) begin
                    valid_uart <= 1'b0;
                    flag <= 1'b1;
                end
            end
        end
    end
    ANN dut(
        .s_axi_aclk(clock),
        .s_axi_aresetn(!reset),
        .x0_out(in2),
        .o0_valid(in_valid),
        .x0_uart(out_rx_fifo),
        .uart_rx_data_ready(valid_uart),
        .out(out_data_ann),
        .out_valid(out_valid),
        //.uart_rx_data(uart_rx_data),
        .stickey(stickey),
        .mode(mode),
        .weightValid(weightValid),
        .biasValid(biasValid),
        .weightValue(weightValue),
        .biasValue(biasValue),
        .config_layer_num(config_layer_num),
        .config_neuron_num(config_neuron_num)
    );
    
    sseg_top SSD1 (
    .clk(clock),
    .sw(out_data_ann[15:0]),
    .seg(seg),
    .an(digits));
endmodule
