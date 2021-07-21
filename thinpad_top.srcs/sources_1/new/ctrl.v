`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/19 15:49:00
// Design Name: 
// Module Name: ctrl
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

module ctrl (
    input clk,
    input rst,
    input from_ex,
    output reg stall
);
reg [1:0]counter;
always @(*) begin
    if(rst) begin
        stall <= 6'b0;
        counter <= 2'b0;
    end else begin
        if(from_ex == 1'b1)begin
            stall <= 1'b1; //说明data用到了baseROM
        end
    end
end  

always @(posedge clk) begin
    if(stall == 1'b1 && counter <2'h2) begin
        counter <= counter + 1'b1;
    end else begin
        if(stall == 1'b1)begin
            stall <= 1'b0;
            counter <= 2'b0;
        end
    end
end  
endmodule
