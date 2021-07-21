`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:15:57 AM
// Design Name: 
// Module Name: mux_3
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


module mux_3(
    input [1:0]sel,
    input wire [31:0]in_1,
    input wire [31:0]in_3,
    input wire [31:0]in_2,
    output wire [31:0]out
);
assign out = (sel == 2'b00) ? in_1 : 
             (sel == 2'b01) ? in_2 :
             (sel == 2'b10) ? in_3 :
             32'h000000000;
endmodule
