`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:12:29 AM
// Design Name: 
// Module Name: mux_2
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


module mux_2(//大概准备给选B和mem 
    input sel,
    input wire [31:0]in_1,
    input wire [31:0]in_2,
    output wire [31:0]out
);
assign out = (sel == 1'b0) ? in_1 : in_2;
endmodule
