`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:18:41 AM
// Design Name: 
// Module Name: pc
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


module pc (
    input wire clk,
    input wire rst,
    input wire zero_in,
    input wire [31:0]targe_adder,
    output reg ce,
    //input wire [5:0]stall,
    output reg [31:0]pc
);
always @(posedge clk) begin
    if (rst == 1'b1) begin
      ce <= 1'b0;
    end
    else begin
      ce <= 1'b1;
    end
end
always @(posedge clk)begin
    if(rst == 1'b1 || ce == 1'b0)begin
        pc <= 32'h80000000;
    end
    else begin
        if(zero_in == 1'b1)begin
            pc <= pc + targe_adder ;
        end
        else begin
            //if(stall != 1'b1)begin
                pc <= pc + 4'h4;
            //end
        end
    end
end
endmodule
