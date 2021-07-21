`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 09:56:18 AM
// Design Name: 
// Module Name: ALU
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


module ALU (
    input [1:0]aluop,
    input [1:0]b,//用来判断是不是branch
    input wire [31:0]scaeA,
    input wire [31:0]scaeB,
    output reg  [31:0]resultALU,
    output reg zero
);
always @(*) begin
    case (aluop)
        2'b00: resultALU <= scaeA + scaeB;
        2'b01: resultALU <= scaeA - scaeB;
        2'b10: resultALU <= scaeA | scaeB;
        default: 
            resultALU <= 32'h00000000;
    endcase
    if(b != 2'b00)begin
        case (b)
            2'b01: begin
                if(resultALU != 32'h00000000)begin
                    zero <= 1'b1;
                end
            end
            default: begin
                zero <= 1'b0;
            end
        endcase
    end else begin
        zero <= 1'b0;
        
    end
end
endmodule