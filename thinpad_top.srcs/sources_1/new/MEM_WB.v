module MEM_WB (
    input rst,
    input clk,

    input [5:0]stall,

    input [31:0]mem_to_wb_ALU_result_i,
    input [4:0]mem_to_wb_reg_waddr_i,
    input mem_to_wb_reg_wen_i,

    output reg [31:0]mem_to_wb_data_o,
    output reg [4:0]mem_to_wb_reg_waddr_o,
    output reg mem_to_wb_reg_wen_o
);

always @(posedge clk) begin
    if(rst)begin
        mem_to_wb_data_o <= 32'h00000000;
        mem_to_wb_reg_waddr_o <= 5'b00000;
        mem_to_wb_reg_wen_o <= 1'b0;
    end else begin
        if(stall[4] == 1'b1 && stall[5] == 1'b0)begin
            mem_to_wb_data_o <= 32'h00000000;
            mem_to_wb_reg_waddr_o <= 5'b00000;
            mem_to_wb_reg_wen_o <= 1'b0;
        end else begin
            if(stall[4] == 1'b0)begin
                mem_to_wb_data_o <= mem_to_wb_ALU_result_i;
                mem_to_wb_reg_waddr_o <= mem_to_wb_reg_waddr_i;
                mem_to_wb_reg_wen_o <= mem_to_wb_reg_wen_i; 
            end
        end      
    end   
end
endmodule