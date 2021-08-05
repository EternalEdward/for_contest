`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:19:34 AM
// Design Name: 
// Module Name: regflie
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


module regfile (
    input clk,
    input rst,
    
    input ren1,
    input [4:0]raddr1,
    input ren2,
    input [4:0]raddr2,

    input we,//写使能
    input [4:0]waddr,
    input [31:0]wdata,

    output wire [31:0] rdata1,
    output wire [31:0] rdata2

);
reg [31:0] regs[31:0];

always @(posedge clk) begin
    if(rst == 1'b1)begin
      regs[ 0] <= 32'h00000000;
      regs[ 1] <= 32'h00000000;
      regs[ 2] <= 32'h00000000;
      regs[ 3] <= 32'h00000000;
      regs[ 4] <= 32'h00000000;
      regs[ 5] <= 32'h00000000;
      regs[ 6] <= 32'h00000000;
      regs[ 7] <= 32'h00000000;
      regs[ 8] <= 32'h00000000;
      regs[ 9] <= 32'h00000000;
      regs[10] <= 32'h00000000;
      regs[11] <= 32'h00000000;
      regs[12] <= 32'h00000000;
      regs[13] <= 32'h00000000;
      regs[14] <= 32'h00000000;
      regs[15] <= 32'h00000000;
      regs[16] <= 32'h00000000;
      regs[17] <= 32'h00000000;
      regs[18] <= 32'h00000000;
      regs[19] <= 32'h00000000;
      regs[20] <= 32'h00000000;
      regs[21] <= 32'h00000000;
      regs[22] <= 32'h00000000;
      regs[23] <= 32'h00000000;
      regs[24] <= 32'h00000000;
      regs[25] <= 32'h00000000;
      regs[26] <= 32'h00000000;
      regs[27] <= 32'h00000000;
      regs[28] <= 32'h00000000;
      regs[29] <= 32'h00000000;
      regs[30] <= 32'h00000000;
      regs[31] <= 32'h00000000;

    end
    if(we)begin
        regs[waddr] <= wdata;
    end
end
//前推了一下
assign rdata1 = ( raddr1 == waddr && we && ren1) ? wdata   : 
                ( raddr1 != 5'b00000 && ren1) ? regs[raddr1] : 
                32'h00000000;

assign rdata2 = ( raddr2 == waddr && we && ren2) ? wdata        : 
                (raddr2 != 5'b00000 && ren2) ? regs[raddr2] : 
                32'h00000000;

endmodule
