module EXE_MEM (
    input clk,
    input rst,

    input [5:0]stall,
    input [31:0]exe_to_mem_ALU_result_i,
    input [4:0]exe_to_mem_reg_waddr_i,
    input exe_to_mem_reg_wen_i,

    input [7:0] exe_alu_op_i,
    input [31:0] exe_to_mem_addr_i,
    input [31:0] exe_caseB_i,

    output reg [7:0] exe_alu_op_o,
    output reg[31:0] exe_to_mem_addr_o,
    output reg[31:0] exe_caseB_o,

    output reg [31:0]exe_to_mem_ALU_result,
    output reg [4:0]exe_to_mem_reg_waddr_o,
    output reg exe_to_mem_reg_wen_o
);
    always @(posedge clk) begin
        if(rst)begin
            exe_to_mem_ALU_result <= 32'h00000000;
            exe_to_mem_reg_waddr_o <= 5'b00000;
            exe_to_mem_reg_wen_o <= 1'b0;
            exe_alu_op_o <= 8'h00000000;
            exe_to_mem_addr_o <= 32'h00000000;
            exe_caseB_o <= 32'h00000000;
        end else begin
            if(stall[3] == 1'b1 && stall[4] == 1'b0)begin
                exe_to_mem_ALU_result <= 32'h00000000;
                exe_to_mem_reg_waddr_o <= 5'b00000;
                exe_to_mem_reg_wen_o <= 1'b0;
                exe_alu_op_o <= 8'h00000000;
                exe_to_mem_addr_o <= 32'h00000000;
                exe_caseB_o <= 32'h00000000;
            end else begin
                if(stall[3] == 1'b0)begin
                    exe_to_mem_ALU_result <= exe_to_mem_ALU_result_i;
                    exe_to_mem_reg_waddr_o <= exe_to_mem_reg_waddr_i;
                    exe_to_mem_reg_wen_o <= exe_to_mem_reg_wen_i;
                    exe_alu_op_o <= exe_alu_op_i;
                    exe_to_mem_addr_o <= exe_to_mem_addr_i;
                    exe_caseB_o <= exe_caseB_i;
                end
            end
        end
    end
endmodule