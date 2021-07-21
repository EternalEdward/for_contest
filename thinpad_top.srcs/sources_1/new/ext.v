`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:04:11 AM
// Design Name: 
// Module Name: ext
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


module ext (
    input wire [1:0]sel,
    input wire [15:0]old_imm,
    output reg [31:0]new_imm
);
always @(*) begin
    case (sel)
        2'b00: new_imm <= {16'h0000,old_imm};//无符号
        2'b01: new_imm <= {old_imm,16'h0000};//16  imm高位
        2'b10: new_imm <= {{16{old_imm[15]}},old_imm};//有符号
        default: begin
            new_imm <= 32'h00000000;
        end
    endcase
end
endmodule
