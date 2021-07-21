`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:15:02 AM
// Design Name: 
// Module Name: mux_2_5
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


module mux_2_5 (
    input [5:0]x,
    input [5:0]y,
    input sel,
    output [5:0]z
);
    assign z = sel ? x : y; 
endmodule
