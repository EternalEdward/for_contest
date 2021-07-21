`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/21 08:23:07
// Design Name: 
// Module Name: leftmove_2
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


module leftmove_2(
    input [15:0]old_imm,
    output [15:0]new_imm
    );
    assign new_imm = old_imm << 2; 
endmodule
