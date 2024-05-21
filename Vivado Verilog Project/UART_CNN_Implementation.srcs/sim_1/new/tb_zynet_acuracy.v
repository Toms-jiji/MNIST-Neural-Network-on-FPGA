`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 16:15:36
// Design Name: 
// Module Name: tb_zynet_acuracy
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

 
`define pretrained
`define numLayers 5
`define dataWidth 16
`define numNeuronLayer0 784
`define numNeuronLayer1 30
`define numWeightLayer1 784
`define Layer1ActType "relu"
`define numNeuronLayer2 30
`define numWeightLayer2 30
`define Layer2ActType "relu"
`define numNeuronLayer3 10
`define numWeightLayer3 30
`define Layer3ActType "relu"
`define numNeuronLayer4 10
`define numWeightLayer4 10
`define Layer4ActType "relu"
`define numNeuronLayer5 10
`define numWeightLayer5 10
`define Layer5ActType "hardmax"
`define sigmoidSize 5
`define weightIntWidth 4
 
`define MaxTestSamples 100

module tb_zynet_acuracy(

    );
    
    reg clock;
    reg reset;
    reg [(784*16)-1:0]in2;
    reg in_valid;
    reg [(784*16)-1:0] out_rx_fifo;
    reg valid_uart;
    reg mode;
    reg [7:0] fileName[23:0];
    
    wire [31:0] out_data_ann;
    wire out_valid;
    wire stickey;
    reg weightValid;
    reg biasValid;
    reg weightValue;
    reg biasValue;
    reg config_layer_num;
    reg config_neuron_num;
    reg [`dataWidth-1:0] in_mem [784:0];
    reg [`dataWidth-1:0] expected;
    
    integer start;
    integer right=0;
    
   zyNet dut(
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
    
    initial begin
        weightValid = 0;
        biasValid = 0;
        weightValue = 0;
        biasValue = 0;
        config_layer_num = 0;
        config_neuron_num = 0;
        out_rx_fifo=1;
        valid_uart=0;
    end
    function [7:0] to_ascii;
      input integer a;
      begin
        to_ascii = a+48;
      end
    endfunction
    
    
    initial begin
        clock =0 ;
    end 
    
    //filename="test.txt";
    always #5 clock = ~clock;
    task sendData();
    //input [(23*7):0] fileName;
    integer t;
    begin
       $readmemb(fileName, in_mem);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        for (t=0; t <784; t=t+1) begin
            @(posedge clock);
          in2[16*t+:16] = in_mem[t];
        end 
                    in_valid <= 1;
                    #1000
 
        @(posedge clock);
        in_valid <= 0;
        expected = in_mem[t];
    end
    endtask
    
    integer i,j,layerNo=1,k;
    integer testDataCount;
    integer testDataCount_int;
    initial begin
        reset= 1;
        #100 
        reset =0;
        mode =0;
        
        start = $time;
        for(testDataCount=0;testDataCount<`MaxTestSamples;testDataCount=testDataCount+1)
        begin
            testDataCount_int = testDataCount;
            fileName[0] = "t";
            fileName[1] = "x";
            fileName[2] = "t";
            fileName[3] = ".";
            fileName[4] = "0";
            fileName[5] = "0";
            fileName[6] = "0";
            fileName[7] = "0";
            i=0;
            while(testDataCount_int != 0)
            begin
                fileName[i+4] = to_ascii(testDataCount_int%10);
                testDataCount_int = testDataCount_int/10;
                i=i+1;
            end 
            fileName[8] = "_";
            fileName[9] = "a";
            fileName[10] = "t";
            fileName[11] = "a";
            fileName[12] = "d";
            fileName[13] = "_";
            fileName[14] = "t";
            fileName[15] = "s";
            fileName[16] = "e";
            fileName[17] = "t";
        sendData();
        @(posedge out_valid);
        
        if(out_data_ann[15:0] == expected)
            right = right+1;
        
        $display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x, Right %0x",testDataCount+1,right*100.0/(testDataCount+1),out_data_ann,expected,right);
    end
 end   
    
   
endmodule
